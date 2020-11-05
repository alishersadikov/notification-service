class Notification < ApplicationRecord
  has_one :child, class_name: 'Notification', foreign_key: 'notification_id'
  belongs_to :parent, class_name: 'Notification', foreign_key: 'notification_id', optional: true
end
