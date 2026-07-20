# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :items, dependent: :restrict_with_exception

  validates :name, presence: true, uniqueness: true, length: { maximum: 100 }
end
