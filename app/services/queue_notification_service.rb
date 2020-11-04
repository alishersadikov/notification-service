# frozen_string_literal: true
class QueueNotificationService
  def self.process(**args)
    new(args).process
  end

  def initialize(number:, message:)
    @number = number
    @message = message
  end

  def process
    determine_provider_url
    create_notification
    queue_notification
  end

  def determine_provider_url
    @provider_url = LoadBalancerService.process
  end

  def create_notification
    @notification = Notification.create!(
      number: @number,
      text: @message,
      provider_url: @provider_url
    )
  end

  def queue_notification
    return unless @notification

    ngrok_host = File.open('.ngrok_host').read

    params = {
      "to_number": @notification.number,
      "message": @notification.text,
      "callback_url": "#{ngrok_host}/delivery_status"
    }

    HTTParty.post(@notification.provider_url, params: params.to_json)
  end
end
