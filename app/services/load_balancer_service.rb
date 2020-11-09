# frozen_string_literal: true

class LoadBalancerService
  def self.process
    new.process
  end

  NoAvailableProviders = Class.new(StandardError)

  def process
    raise NoAvailableProviders if Provider.count.zero?

    breakdown = calculated_breakdown

    breakdown.each do |provider|
      if provider['load'] < (provider['weight'] / 100)
        Rails.logger.info "LoadBalancerService#process - sending to provider id: '#{provider['id']}'"
        return provider['id']
      end
    end

    provider_id = breakdown.first['id']
    Rails.logger.info "LoadBalancerService#process - sending to provider id: '#{provider_id}'"
    provider_id
  end

  def calculated_breakdown
    sql = <<-SQL
      SELECT providers.id as id, providers.weight as weight, COALESCE(loads.current_load, 0) as load
      FROM (
        SELECT provider_id, COUNT(*) / CAST( SUM(count(*)) over () as float ) as current_load
        FROM notifications
        WHERE status = 'queued'
        GROUP BY provider_id
      ) AS loads
      RIGHT JOIN providers ON loads.provider_id = providers.id
      GROUP BY providers.id, providers.weight, loads.current_load
      ORDER BY providers.id
    SQL

    ActiveRecord::Base.connection.execute(sql).to_a
  end
end
