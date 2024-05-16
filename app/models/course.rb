class Course < ApplicationRecord
  include CustomValidations

  has_many :course_modules, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments

  has_one_attached :banner
  validate :acceptable_banner

  def enroll(user)
    enrollments.create!(user: user)
  end
  def undo_enroll(user)
    enrollments.where(user: user).delete_all
  end
end
