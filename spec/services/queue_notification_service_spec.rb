require 'rails_helper'

RSpec.describe QueueNotificationService do
  let(:number) { Faker::Number.number(digits: 10).to_s }
  let(:message) { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
  let(:service) { QueueNotificationService.new(number: number, message: message) }
  let(:provider_url) { ENV['PROVIDER_1_URL'] }

  before do
    allow(LoadBalancerService).to receive(:process).and_return(provider_url)

    stub_request(:post, ENV['PROVIDER_1_URL']).
      to_return(status: 200, body: "stubbed response"
    )
  end

  context '#initialize' do
    it 'expects number and message paramerters' do
      expect { QueueNotificationService.process }.to raise_error(ArgumentError)

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
      expect(Notification).to receive(:create!).with(
        number: number,
        text: message,
        provider_url: provider_url
      )

      service.process
    end
  end

  context '#queue_notification' do
    it 'relies on the dedicated service' do
      params = {
        "to_number": number,
        "message": message,
        "callback_url": "#{File.open('.ngrok_host').read}/delivery_status"
      }

      expect(HTTParty).to receive(:post).with(provider_url, params: params.to_json)
      service.process
    end
  end
end