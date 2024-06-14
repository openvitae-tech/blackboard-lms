class Course < ApplicationRecord
  include CustomValidations

  has_many :course_modules, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments

  has_one_attached :banner
  validate :acceptable_banner

  def enroll!(user)
    enrollments.create!(user: user)
  end
  def undo_enroll!(user)
    # there will be only one enrollment record for a user, course pair
    enrollments.where(user: user).delete_all
  end

  def duration
    course_modules.map(&:duration).reduce(&:+) || 0
  end

  def lessons_count
    course_modules.map(&:lessons_count).reduce(:+) || 0
  end

  def quizzes_count
    course_modules.map(&:quizzes_count).reduce(:+) || 0
  end
end
