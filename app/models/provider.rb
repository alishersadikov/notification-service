# frozen_string_literal: true

class Provider < ApplicationRecord
  has_many :notifications

  validates :url, :weight, presence: true
end
