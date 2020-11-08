# frozen_string_literal: true
class HandleCallbackService
  def self.process(**args)
    new(args).process
  end

  def initialize(external_id:, status:)
    @external_id = external_id
    @status = status
  end

  def process
    notification = Notification.find_by!(external_id: @external_id)
    notification.update!(status: @status)

    return if %w[invalid delivered].include?(@status)
    return unless @status == 'failed'
    return if notification.direct_parent_count >= Notification::RETRY_LIMIT

    RetryNotificationService.process(parent: notification)
  end
end
