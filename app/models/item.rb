# frozen_string_literal: true

class Item < ApplicationRecord
  belongs_to :category, optional: true

  validates :name, presence: true
  validates :price, numericality: { greater_than: 0 }
end
