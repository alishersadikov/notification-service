# frozen_string_literal: true

class AddProviderIdToNotification < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :provider, foreign_key: true
    remove_column :notifications, :provider_url
  end
end
