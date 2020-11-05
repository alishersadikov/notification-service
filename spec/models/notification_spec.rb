require 'rails_helper'

RSpec.describe Notification do
  context '#direct_parent_count' do
    it 'returns 0 if no parent' do
      notification = FactoryBot.create(:notification, :provider_1)

      expect(notification.parent).to be_nil
      expect(notification.direct_parent_count).to eq(0)
    end

    it 'returns 1 for direct parent' do
      notification = FactoryBot.create(:notification, :provider_1)
      notification.child = FactoryBot.create(:notification, :provider_1)

      expect(notification.child.parent).to be_present
      expect(notification.child.direct_parent_count).to eq(1)
    end

    it 'returns 0 for indirect parent' do
      notification = FactoryBot.create(:notification, :provider_1)
      notification.child = FactoryBot.create(:notification, :provider_2)

      expect(notification.child.parent).to be_present
      expect(notification.child.direct_parent_count).to eq(0)
    end

    it 'returns count for and uninterrupted chain/ancestry' do
      notification = FactoryBot.create(:notification, :provider_1)
      notification.child = FactoryBot.create(:notification, :provider_2)
      notification.child.child = FactoryBot.create(:notification, :provider_2)

      expect(notification.child.child.parent).to be_present
      expect(notification.child.child.direct_parent_count).to eq(1)
    end
  end
end
