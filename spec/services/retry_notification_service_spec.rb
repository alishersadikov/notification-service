require 'rails_helper'

RSpec.describe RetryNotificationService do
  let(:service) { RetryNotificationService }
  let(:notification) { FactoryBot.create(:notification, :queued, :provider_1) }

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
    it 'creates and queues child notification' do
      expect(QueueNotificationService).to receive(:process)

      service.process(parent: notification, flip_provider: true)

      expect(notification.status).to eq(notification.child.status)
      expect(notification.message).to eq(notification.child.message)
      expect(notification.child.parent).to match(notification)
      expect(notification.provider_url).to_not eq(notification.child.provider_url)
    end
  end

  context 'with the same provider' do
    it 'creates and queues child notification' do
      expect(QueueNotificationService).to receive(:process)

      service.process(parent: notification)

      expect(notification.status).to eq(notification.child.status)
      expect(notification.message).to eq(notification.child.message)
      expect(notification.child.parent).to match(notification)
      expect(notification.provider_url).to eq(notification.child.provider_url)
    end
  end

  context '#alternative_provider_url' do
    it 'returns the other provider\'s url' do
      notification_1 = FactoryBot.create(:notification, :queued, :provider_1)
      notification_2 = FactoryBot.create(:notification, :queued, :provider_2)

      service = RetryNotificationService.new(parent: notification_1, flip_provider: true)

      expect(service.alternative_provider_url).to eq(ENV.fetch('PROVIDER_2_URL'))

      service = RetryNotificationService.new(parent: notification_2, flip_provider: true)

      expect(service.alternative_provider_url).to eq(ENV.fetch('PROVIDER_1_URL'))
    end
  end
end
