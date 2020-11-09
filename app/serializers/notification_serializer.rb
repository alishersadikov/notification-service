# frozen_string_literal: true

class NotificationSerializer
  include JSONAPI::Serializer

  attributes :number, :message, :status, :external_id, :provider_url, :created_at, :updated_at, :notification_id
  belongs_to :provider
end
