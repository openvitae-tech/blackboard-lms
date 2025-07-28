# frozen_string_literal: true

class Program < ApplicationRecord
  validates :name, presence: true
  validate :must_have_at_least_one_course

  has_many :program_courses, dependent: :destroy
  has_many :courses, through: :program_courses

  has_many :program_users, dependent: :destroy
  has_many :users, through: :program_users

  belongs_to :learning_partner

  private

  def must_have_at_least_one_course
    return if courses.present?

    errors.add(:base, 'Atleast one course should be selected')
  end
end
