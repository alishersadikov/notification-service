namespace :notifications do
  desc 'Generate a single or multiple notifications'
  task :generate, [:quantity] => [:environment] do |t, args|
    quantity = args[:quantity].present? ? args[:quantity] : '1'

    puts "Requested '#{quantity}' records"

    quantity.to_i.times do
      FactoryBot.create(:notification, :queued, provider: Provider.all.sample)
    end

    puts 'Generated the records'
  end
end