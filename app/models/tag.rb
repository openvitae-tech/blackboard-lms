# frozen_string_literal: true

class Tag < ApplicationRecord

  DEFAULT_PER_PAGE_SIZE = 9

  enum tag_type: { category: "category", level: "level" }, _default: "category"

  validates :name, presence: true, uniqueness: true
  validates :tag_type, presence: true

  has_and_belongs_to_many :courses
end
