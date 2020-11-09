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
      'callback_url': "#{callback_host}/delivery_status"
    }


    @response = HTTParty.post(
      @notification.provider.url,
      body: body.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    Rails.logger.info "QueueNotificationService#process: provider response: '#{@response.inspect}'"
  end

  def process_response
    parsed_response = JSON.parse(@response.body)
    if @response.code == 200 && parsed_response['message_id']
      @notification.update(external_id: parsed_response['message_id'], status: 'queued')
    end

    return unless @response.code == 500

    @notification.update(status: 'failed')
    RetryNotificationService.process(parent: @notification, flip_provider: true)
  end

  def callback_host
    File.open('.ngrok_host').read if Rails.env.development?
    ENV['NOTIFICATION_SERVICE_HOST']
  end
end
