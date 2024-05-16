class Course < ApplicationRecord
  include CustomValidations

  has_many :course_modules, dependent: :destroy

  has_one_attached :banner
  validate :acceptable_banner
end
