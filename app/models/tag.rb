# frozen_string_literal: true

class Tag < ApplicationRecord

  enum tag_type: { category: "category", level: "level" }, _default: "category"

  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :courses
end
