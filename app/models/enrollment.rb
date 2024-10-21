# frozen_string_literal: true

class Enrollment < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :course, counter_cache: true
  belongs_to :assigned_by, class_name: 'User', foreign_key: 'assigned_by_id', optional: true
  has_many :quiz_answers, dependent: :destroy

  validates :user_id, uniqueness: { scope: :course_id }

  def complete_lesson!(module_id, lesson_id, time_spent_in_seconds)
    self.current_module_id = module_id
    self.current_lesson_id = lesson_id
    unless completed_lessons.include? lesson_id
      completed_lessons.push(lesson_id)
      self.time_spent += time_spent_in_seconds
    end
    save!
  end

  def complete_module!(module_id)
    return if completed_modules.include? module_id

    completed_modules.push(module_id)
    save!
  end

  def complete_course!
    return if course_completed

    self.course_completed = true
    save!
  end

  # TODO: The id list on the completed_lessons needs a cleanup on deleting a lesson
  # The same applies to current_module_id and current_lesson_id attributes
  # A cleanup has to be performed on all the related enrollment records
  def quiz_answered?(quiz)
    quiz_answers.exists?(quiz:)
  end

  def get_answer(quiz)
    quiz_answers.where(quiz:).first
  end

  def module_completed?(module_id)
    completed_modules.include? module_id
  end
end
