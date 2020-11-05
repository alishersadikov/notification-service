# frozen_string_literal: true
class LoadBalancerService
  def self.process
    new.process
  end

  def initialize
    @provider_1_url = ENV.fetch('PROVIDER_1_URL')
    @provider_2_url = ENV.fetch('PROVIDER_2_URL')
  end

  def process
    actual_ratio >= target_ratio ? @provider_2_url : @provider_1_url
  end

  def current_breakdown
    @current_breakdown ||= Notification.where(status: 'queued').group(:provider_url).count
  end

  def provider_1_load
    current_breakdown[@provider_1_url] || 0
  end

  def provider_2_load
    current_breakdown[@provider_2_url] || 0
  end

  def actual_ratio
    @actual_ratio ||= calculate_actual_ratio
  end

  def target_ratio
    provider_1_weight = ENV.fetch('PROVIDER_1_WEIGHT', '30').to_f
    provider_2_weight = ENV.fetch('PROVIDER_2_WEIGHT', '70').to_f
    @target_ratio ||= provider_1_weight / provider_2_weight
  end

  def calculate_actual_ratio
    # dividing by zero is meaningless
    provider_2_load.zero? ? target_ratio : provider_1_load.to_f / provider_2_load
  end
end
