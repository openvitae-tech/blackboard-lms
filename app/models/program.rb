# frozen_string_literal: true

class Program < ApplicationRecord
  DEFAULT_PER_PAGE_SIZE = 10

  validates :name, presence: true

  has_many :program_courses, dependent: :destroy
  has_many :courses, through: :program_courses

  has_many :program_users, dependent: :destroy
  has_many :users, through: :program_users

  belongs_to :learning_partner

  scope :filter_by_name, ->(str) { where('name ILIKE ?', "%#{sanitize_sql_like(str)}%") }
end
