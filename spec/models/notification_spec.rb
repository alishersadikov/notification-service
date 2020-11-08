require 'rails_helper'

RSpec.describe Notification do
  context 'validations' do
    it 'number must be present, numerical and 10 digits' do
      expect(
        Notification.new(
          message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
          provider_url: Faker::Internet.url,
          status: 'created'
        )
      ).to_not be_valid

      expect(
        Notification.new(
          number: Faker::Number.number(digits: 9),
          message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
          provider_url: Faker::Internet.url,
          status: 'created'
        )
      ).to_not be_valid

      expect(
        Notification.new(
          number: Faker::Number.number(digits: 11),
          message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
          provider_url: Faker::Internet.url,
          status: 'created'
        )
      ).to_not be_valid

      expect(
        Notification.new(
          number: 'abcdefghij',
          message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
          provider_url: Faker::Internet.url,
          status: 'created'
        )
      ).to_not be_valid

      expect(
        Notification.new(
          number: Faker::Number.number(digits: 10),
          message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
          provider_url: Faker::Internet.url,
          status: 'created'
        )
      ).to be_valid
    end

    it 'message must be present' do
      expect(
        Notification.new(
          number: Faker::Number.number(digits: 10),
          status: 'created'
        )
      ).to_not be_valid

      expect(
        Notification.new(
          number: Faker::Number.number(digits: 10),
          message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
          provider_url: Faker::Internet.url,
          status: 'created'
        )
      ).to be_valid
    end

    it 'provider_url must be present' do
      expect(
        Notification.new(
          number: Faker::Number.number(digits: 10),
          message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
          status: 'created'
        )
      ).to_not be_valid

      expect(
        Notification.new(
          number: Faker::Number.number(digits: 10),
          message: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
          provider_url: Faker::Internet.url,
          status: 'created'
        )
      ).to be_valid
    end

    it 'status must be present' do
      %w(created queued invalid delivered failed).each do |status|
        expect(
          Notification.new(
            number: Faker::Number.number(digits: 10),
            message: Faker::Lorem.sentence(word_count: 3, supplemental: true),
            provider_url: Faker::Internet.url,
            status: status
          )
        ).to be_valid
      end

      expect(
        Notification.new(
          number: Faker::Number.number(digits: 10),
          message: Faker::Lorem.paragraph_by_chars(number: 256, supplemental: false),
          provider_url: Faker::Internet.url,
          status: 'non_existent'
        )
      ).to_not be_valid
    end
  end

  context '#direct_parent_count' do
    it 'returns 0 if no parent' do
      notification = FactoryBot.create(:notification, :provider_1, :queued)

      expect(notification.parent).to be_nil
      expect(notification.direct_parent_count).to eq(0)
    end

    it 'returns 1 for direct parent' do
      notification = FactoryBot.create(:notification, :provider_1, :queued)
      notification.child = FactoryBot.create(:notification, :provider_1, :queued)

      expect(notification.child.parent).to be_present
      expect(notification.child.direct_parent_count).to eq(1)
    end

    it 'returns 0 for indirect parent' do
      notification = FactoryBot.create(:notification, :provider_1, :queued)
      notification.child = FactoryBot.create(:notification, :provider_2, :queued)

      expect(notification.child.parent).to be_present
      expect(notification.child.direct_parent_count).to eq(0)
    end

    it 'returns count for an uninterrupted chain/ancestry' do
      notification = FactoryBot.create(:notification, :provider_1, :queued)
      notification.child = FactoryBot.create(:notification, :provider_2, :queued)
      notification.child.child = FactoryBot.create(:notification, :provider_2, :queued)

      expect(notification.child.child.parent).to be_present
      expect(notification.child.child.direct_parent_count).to eq(1)
    end
  end
end
