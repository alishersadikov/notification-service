class Notification < ApplicationRecord
  has_one :child, class_name: 'Notification', foreign_key: 'notification_id'
  belongs_to :parent, class_name: 'Notification', foreign_key: 'notification_id', optional: true

  validates :number, presence: true,
                     numericality: true,
                     length: { minimum: 10, maximum: 10 }

  validates :message, presence: true
  validates :provider_url, presence: true
  validates :status, inclusion: { in: %w[created queued invalid delivered failed] }

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
