# require 'factory_bot'

namespace :notifications do
  desc 'generate'
  task :generate, [:quantity] => [:environment] do |t, args|
    quantity = args[:quantity].present? ?  args[:quantity] : '1'

    puts "Requested '#{quantity}' records"

    records = FactoryBot.create_list(
      :notification,
      quantity.to_i,
      :queued,
      provider: Provider.all.sample
    )

    puts "Generated '#{records.count}' records"
  end
end