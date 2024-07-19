class Course < ApplicationRecord
  include CustomValidations

  has_many :course_modules, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :users, through: :enrollments

  has_one_attached :banner
  validate :acceptable_banner

  def enroll!(user, assigned_by = nil)
    enrollments.create!(user: user, assigned_by: assigned_by)
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

  def first_module
    first_module_id = course_modules_in_order.first
    course_modules.find(first_module_id) if first_module_id.present?
  end

  def last_module
    last_module_id = course_modules_in_order.last
    course_modules.find(last_module_id) if last_module_id.present?
  end

  def next_module(current_module)
    index = course_modules_in_order.find_index(current_module.id)
    course_modules.find(course_modules_in_order[index + 1]) if course_modules_in_order[index + 1].present?
  end

  def prev_module(current_module)
    index = course_modules_in_order.find_index(current_module.id)
    course_modules.find(course_modules_in_order[index - 1]) if course_modules_in_order[index - 1].present?
  end
end
