class Notification < ApplicationRecord
  has_one :child, class_name: 'Notification', foreign_key: 'notification_id'
  belongs_to :parent, class_name: 'Notification', foreign_key: 'notification_id', optional: true

  # direct in the sense that provider is shared
  def direct_parent_count
    return 0 unless parent.present?

    if provider_url == parent.provider_url
      parent.direct_parent_count + 1
    else
      parent.direct_parent_count
    end
  end
end
