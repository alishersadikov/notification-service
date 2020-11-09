# frozen_string_literal: true

class ProviderSerializer
  include JSONAPI::Serializer
  attributes :url, :weight

  has_many :notifications
end
