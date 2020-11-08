# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HandleCallbackService do
  let(:external_id) { Faker::Internet.uuid }
  let(:number) { Faker::Number.number(digxits: 10).to_s }
  let(:message) { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
  let(:service) { HandleCallbackService.new(external_id: external_id, status: status) }
  let(:provider_url) { ENV['PROVIDER_1_URL'] }

  before do
    allow(LoadBalancerService).to receive(:process).and_return(provider_url)
    allow(QueueNotificationService).to receive(:process).and_return(true)
  end

  context '#initialize' do
    it 'expects external_id and status parameters' do
      FactoryBot.create(:notification, :provider1, :queued, external_id: external_id)

      expect { HandleCallbackService.process }.to raise_error(ArgumentError)

      expect do
        HandleCallbackService.process(external_id: external_id, status: 'delivered')
      end.to_not raise_error
    end
  end

  context '#process' do
    it 'finds the notification based on the external_id and updates status' do
      notification = FactoryBot.create(:notification, :provider1, :queued, external_id: external_id)

      expect(Notification).to receive(:find_by!).with(external_id: external_id).and_return(notification)
      expect(notification).to receive(:update!)

      HandleCallbackService.process(external_id: external_id, status: 'delivered')
    end

    it 'raises an exception if notification not found' do
      expect do
        HandleCallbackService.process(external_id: external_id, status: 'delivered')
      end.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'raises an exception if status is not supported' do
      FactoryBot.create(:notification, :provider1, :queued, external_id: external_id)

      expect do
        HandleCallbackService.process(external_id: external_id, status: 'unknown')
      end.to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Status is not included in the list')
    end

    it 'does not retry if status is invalid or delivered' do
      FactoryBot.create(:notification, :provider1, :queued, external_id: external_id)

      expect(RetryNotificationService).to_not receive(:process)

      HandleCallbackService.process(external_id: external_id, status: %w[delivered invalid].sample)
    end

    it 'retries if status is failed' do
      FactoryBot.create(:notification, :provider1, :queued, external_id: external_id)

      expect(RetryNotificationService).to receive(:process)

      HandleCallbackService.process(external_id: external_id, status: 'failed')
    end
  end

  context 'retry limit' do
    it 'keeps retrying up to 3 generations' do
      notification1 = FactoryBot.create(:notification, :provider1, status: 'failed', external_id: Faker::Internet.uuid)

      external_id = Faker::Internet.uuid
      notification1.child = FactoryBot.create(:notification, :provider1, :queued, external_id: external_id)

      expect(RetryNotificationService).to receive(:process)

      HandleCallbackService.process(external_id: external_id, status: 'failed')
    end

    it 'stops retrying after 3 generations' do
      notification1 = FactoryBot.create(:notification, :provider1, status: 'failed', external_id: Faker::Internet.uuid)
      notification2 = FactoryBot.create(:notification, :provider1, status: 'failed', external_id: Faker::Internet.uuid)
      notification1.child = notification2

      external_id = Faker::Internet.uuid
      notification2.child = FactoryBot.create(:notification, :provider1, status: 'failed', external_id: external_id)

      expect(RetryNotificationService).to_not receive(:process)

      HandleCallbackService.process(external_id: external_id, status: 'failed')
    end
  end
end
