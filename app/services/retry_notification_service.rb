# frozen_string_literal: true

class RetryNotificationService
  def self.process(**args)
    new(args).process
  end

  def initialize(parent:, flip_provider: false)
    @parent = parent
    @flip_provider = flip_provider
  end

  def process
    child = @parent.dup
    child.provider_url = alternative_provider_url if @flip_provider
    child.save!
    @parent.child = child

    QueueNotificationService.process(notification: child)
  end

  def alternative_provider_url
    provider_urls = [ENV.fetch('PROVIDER_1_URL'), ENV.fetch('PROVIDER_2_URL')]
    provider_urls.delete(@parent.provider_url)
    provider_urls.first
  end
end
