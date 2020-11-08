# frozen_string_literal: true

class Notification < ApplicationRecord
  RETRY_LIMIT = 2

  has_one :child, class_name: 'Notification', foreign_key: 'notification_id'
  belongs_to :parent, class_name: 'Notification', foreign_key: 'notification_id', optional: true
  belongs_to :provider

  validates :number, presence: true,
                     numericality: true,
                     length: { minimum: 10, maximum: 10 }

  validates :message, presence: true
  validates :status, inclusion: { in: %w[created queued invalid delivered failed] }

  scope :queued, -> { where(status: 'queued') }

  # direct means shared provider_url
  def direct_parent_count
    return 0 unless parent.present?

    if provider.id == parent.provider.id
      parent.direct_parent_count + 1
    else
      parent.direct_parent_count
    end
  end
end
