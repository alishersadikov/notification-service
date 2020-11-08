require 'rails_helper'

RSpec.describe QueueNotificationService do
  let(:service) { QueueNotificationService }
  let(:notification) { FactoryBot.create(:notification, :queued, :provider_1) }
  let(:response) { {'message_id': 'e39b9fd2-3e4f-42e7-8c2c-1770773da8a8'} }

  before do
    stub_request(:post, ENV['PROVIDER_1_URL']).to_return(
      status: 200,
      body: response.to_json
    )
  end

  context '#initialize' do
    it 'expects number and message parameters' do
      expect { service.process }.to raise_error(ArgumentError)
      expect { service.process(notification: notification) }.to_not raise_error
    end
  end

  context 'successful response' do
    it 'records the external_id' do
      service.process(notification: notification)

      expect(notification.external_id).to eq(response[:message_id])
    end
  end

  context 'failure response' do
    it 'invokes the retry service ' do
      stub_request(:post, ENV['PROVIDER_1_URL']).to_return(
        status: 500,
        body: { 'error': 'Something went wrong' }.to_json
      )

      expect(RetryNotificationService).to receive(:process)
        .with(parent: notification, flip_provider: true)

      service.process(notification: notification)

      expect(notification.external_id).to be_nil
    end
  end
end
