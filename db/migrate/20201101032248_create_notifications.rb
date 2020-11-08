# frozen_string_literal: true

class CreateNotifications < ActiveRecord::Migration[6.0]
  def change
    create_table :notifications do |t|
      t.string :number
      t.text :message
      t.string :status
      t.string :provider_url
      t.uuid :external_id
      t.timestamps
    end

    add_index :notifications, :number
    add_index :notifications, :status
    add_index :notifications, :provider_url
    add_index :notifications, :external_id
  end
end
