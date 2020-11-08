# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RetryNotificationService do
  let(:service) { RetryNotificationService }
  let(:provider) { FactoryBot.create(:provider) }
  let(:provider2) { FactoryBot.create(:provider) }
  let(:notification) { FactoryBot.create(:notification, :queued, provider: provider) }

  before do
    allow(QueueNotificationService).to receive(:process).and_return(true)
  end

  context '#initialize' do
    it 'expects parent parameter' do
      expect { service.process }.to raise_error(ArgumentError)
      expect { service.process(parent: notification) }.to_not raise_error
    end
  end

  context 'with flipped provider' do
    it 'raises an exception if alternative provider is not available' do
      expect(QueueNotificationService).to_not receive(:process)

      expect { service.process(parent: notification, flip_provider: true) }.to raise_error(RetryNotificationService::NoAlternativeProviders)
    end

    it 'creates and queues child notification' do
      provider2 # create the alternative provider

      expect(QueueNotificationService).to receive(:process)

      service.process(parent: notification, flip_provider: true)

      expect(notification.status).to eq(notification.child.status)
      expect(notification.message).to eq(notification.child.message)
      expect(notification.child.parent).to match(notification)
      expect(notification.provider).to_not match(notification.child.provider)
    end
  end

  context 'with the same provider' do
    it 'creates and queues child notification' do
      expect(QueueNotificationService).to receive(:process)

      service.process(parent: notification)

      expect(notification.status).to eq(notification.child.status)
      expect(notification.message).to eq(notification.child.message)
      expect(notification.child.parent).to match(notification)
      expect(notification.provider).to match(notification.child.provider)
    end
  end

  context '#alternative_provider' do
    it 'returns the other provider' do
      notification1 = FactoryBot.create(:notification, :queued, provider: provider)
      notification2 = FactoryBot.create(:notification, :queued, provider: provider2)

      service = RetryNotificationService.new(parent: notification1, flip_provider: true)

      expect(service.alternative_provider).to match(provider2)

      service = RetryNotificationService.new(parent: notification2, flip_provider: true)

      expect(service.alternative_provider).to match(provider)
    end
  end
end
