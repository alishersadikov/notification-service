# frozen_string_literal: true

namespace :providers do
  desc 'Recalibrate provider weights'
  task :recalibrate, [:hours] => [:environment] do |_t, args|
    hours = args[:hours].present? ? args[:hours] : '1'

    puts "Requested time frame: '#{hours}' hours"

    breakdown = Notification.where('created_at > ?', hours.to_i.hours.ago).group(:provider_id).count

    failures = breakdown.values
    all_failures = failures.sum
    average = all_failures / failures.size.to_f

    breakdown.each do |provider_id, failure_count|
      provider = Provider.find_by!(id: provider_id)
      delta = (average - failure_count).to_f * 100 / all_failures
      new_weight = provider.weight + delta

      puts "Updating provider # '#{provider}' weight to'#{new_weight}'"

      provider.update(weight: new_weight)
    end
  end
end
