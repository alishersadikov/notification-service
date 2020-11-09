class NotificationSerializer
  include JSONAPI::Serializer

  attributes :number, :message, :status, :external_id, :provider_url
  belongs_to :provider
end
