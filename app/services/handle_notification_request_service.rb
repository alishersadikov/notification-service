# frozen_string_literal: true

class HandleNotificationRequestService
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

    Rails.logger.info "HandleNotificationRequestService#process - "\
      "queued, notification id: '#{@notification.id}'"
  end

  def determine_provider_url
    @provider_id = LoadBalancerService.process
  end

  def create_notification
    @notification = Notification.create!(
      number: @number,
      message: @message,
      provider_id: @provider_id,
      status: 'created'
    )
  end

  def queue_notification
    QueueNotificationService.process(notification: @notification)

    @notification
  end
end
