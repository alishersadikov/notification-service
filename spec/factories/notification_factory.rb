
# frozen_string_literal: true
FactoryBot.define do
  factory :notification do
    number { Faker::Number.number(digits: 10) }
    text { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
    trait :provider_1 do
      provider_url { ENV['PROVIDER_1_URL'] }
    end

    trait :provider_2 do
      provider_url { ENV['PROVIDER_2_URL'] }
    end

    trait :queued do
      status { 'queued' }
    end
  end
end
