# frozen_string_literal: true

namespace :notifications do
  desc 'Generate a single or multiple notifications'
  task :generate, [:quantity] => [:environment] do |_t, args|
    quantity = args[:quantity].present? ? args[:quantity] : '1'

    puts "Requested '#{quantity}' records"

    quantity.to_i.times do
      Notification.create!(
        number: Faker::Number.number(digits: 10).to_s,
        message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
        status: 'queued',
        provider: Provider.all.sample
      )
    end

    puts 'Generated the records'
  end
end
