class AddSelfRefToNotifications < ActiveRecord::Migration[6.0]
  def change
    add_reference :notifications, :notification, foreign_key: true
  end
end
