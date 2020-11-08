# frozen_string_literal: true

FactoryBot.define do
  factory :notification do
    number { Faker::Number.number(digits: 10).to_s }
    message { Faker::Lorem.sentence(word_count: 3, supplemental: true) }
    trait :queued do
      status { 'queued' }
    end
  end
end
