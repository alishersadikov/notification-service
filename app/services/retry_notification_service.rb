# frozen_string_literal: true

class RetryNotificationService
  def self.process(**args)
    new(args).process
  end

  NoAlternativeProviders = Class.new(StandardError)

  def initialize(parent:, flip_provider: false)
    @parent = parent
    @flip_provider = flip_provider
  end

  def process
    Rails.logger.info "RetryNotificationService#process - notification "\
      "id: '#{@parent.id}', flip_provider: '#{@flip_provider}'"

    child = @parent.dup
    child.provider = alternative_provider if @flip_provider
    child.save!
    @parent.child = child

    QueueNotificationService.process(notification: child)
  end

  def alternative_provider
    provider = Provider.where.not(id: @parent.provider_id).first

    raise NoAlternativeProviders unless provider

    provider
  end
end
