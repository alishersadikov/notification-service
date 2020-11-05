# frozen_string_literal: true
class QueueNotificationService
  def self.process(**args)
    new(args).process
  end

  def initialize(notification:)
    @notification = notification
  end

  def process
    post_to_provider
    process_response
  end

  def post_to_provider
    body = {
      'to_number': @notification.number,
      'message': @notification.message,
      'callback_url': "#{ngrok_host}/delivery_status"
    }

    @response = HTTParty.post(@notification.provider_url,
      body: body.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )
  end

  def process_response
    parsed_response = JSON.parse(@response.body)
    if @response.code == 200 && parsed_response['message_id']
      @notification.update(external_id: parsed_response['message_id'])
      return
    end

    if @response.code == 500
      RetryNotificationService.process(parent: @notification, flip_provider: true)
    end
  end

  def ngrok_host
    File.open('.ngrok_host').read
  end
end
