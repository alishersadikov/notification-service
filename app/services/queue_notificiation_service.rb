# frozen_string_literal: true
class QueueNotificationService
  def self.process(**args)
    new(args).process
  end

  def initialize(number:, message:, provider_url:)
    @number = number
    @message = message
    @provider_url = provider_url
  end

  def process
    create_notification
    queue_notification
  end

  def create_notification
    @notification = Notification.create!(
      number: @number,
      text: @message,
      provider_url: provider_url,
    )
  end

  def queue_notification
    params = {
      "to_number": @notification.number,
      "message": @notification.text,
      "callback_url": "host/delivery_status"
    }

    HTTParty.post(@notification.provider_url, params: params.to_json)
  end
end
