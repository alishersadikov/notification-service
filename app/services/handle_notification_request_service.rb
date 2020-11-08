# frozen_string_literal: true

class HandleNotificationRequestService
  def self.process(**args)
    new(args).process
  end

  PersistenceError = Class.new(StandardError)

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
      message: @message,
      provider_url: @provider_url,
      status: 'created'
    )
  end

  def queue_notification
    raise PersistenceError unless @notification&.persisted?

    QueueNotificationService.process(notification: @notification)
  end
end
