# frozen_string_literal: true
class LoadBalancerService
  def self.process(**args)
    new(args).process
  end

  # KeyError if env var does not exist

  def initialize(number:, message:)
    @number = number
    @message = message
  end

  def process
    QueueNotificationService.process(
      number: @number,
      message: @message,
      provider_url: determine_provider_url
    )
  end

  def determine_provider_url
    provider_1_url = ENV.fetch('PROVIDER_1_URL')
    provider_2_url = ENV.fetch('PROVIDER_2_URL')
    provider_1_weight = ENV.fetch('PROVIDER_1_WEIGHT', '30')
    provider_2_weight = ENV.fetch('PROVIDER_2_WEIGHT', '70')

    current_breakdown = Notification.where(status: 'queued').group(:provider_url).count
    provider_1_load = current_breakdown[provider_1_url]
    provider_2_load = current_breakdown[provider_2_url]

    actual_ratio = provider_1_load.to_f / provider_2_load
    target_ratio = provider_1_weight.to_f / provider_2_weight.to_f

    actual_ratio > target_ratio ? provider_2_url : provider_1_url
  end
end
