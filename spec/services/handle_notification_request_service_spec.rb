# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HandleNotificationRequestService do
  let(:number) { Faker::Number.number(digits: 10).to_s }
  let(:message) { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
  let(:service) { HandleNotificationRequestService.new(number: number, message: message) }
  let(:provider) { FactoryBot.create(:provider) }

  before do
    allow(LoadBalancerService).to receive(:process).and_return(provider.id)
    allow(QueueNotificationService).to receive(:process).and_return(true)
  end

  context '#initialize' do
    it 'expects number and message parameters' do
      expect { HandleNotificationRequestService.process }.to raise_error(ArgumentError)

      expect { service.process }.to_not raise_error
    end
  end

  context '#determine_provider_url' do
    it 'relies on the dedicated service' do
      expect(LoadBalancerService).to receive(:process)

      service.process
    end
  end

  context '#create_notification' do
    it 'creates a record' do
      notification = double('notification',
                            number: number,
                            message: message,
                            provider_id: provider.id)

      expect(Notification).to receive(:create!).with(
        number: number,
        message: message,
        provider_id: provider.id,
        status: 'created'
      ).and_return(notification)

      service.process
    end

    it 'raises an exception if attributes are invalid' do
      expect { HandleNotificationRequestService.process(number: nil, message: nil) }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context '#queue_notification' do
    it 'delegates queueing to the dedicated service' do
      expect(QueueNotificationService).to receive(:process)

      service.process
    end
  end
end
