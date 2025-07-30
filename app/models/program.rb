# frozen_string_literal: true

class Program < ApplicationRecord
  validates :name, presence: true

  has_many :program_courses, dependent: :destroy
  has_many :courses, through: :program_courses

  has_many :program_users, dependent: :destroy
  has_many :users, through: :program_users

  belongs_to :learning_partner
end
