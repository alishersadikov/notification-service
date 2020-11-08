# frozen_string_literal: true

FactoryBot.define do
  factory :provider do
    url { Faker::Internet.url }
    weight { rand(100).to_f }
  end
end
