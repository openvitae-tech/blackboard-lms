# frozen_string_literal: true

class Enrollment < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :course, counter_cache: true
  belongs_to :assigned_by, class_name: 'User', optional: true
  has_many :quiz_answers, dependent: :destroy

  validates :user_id, uniqueness: { scope: :course_id }

  scope :completed, -> { where(course_completed: true) }

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

  def lesson_completed?(lesson_id)
    completed_lessons.include? lesson_id
  end

  def mark_as_incomplete!(lesson)
    completed_lessons.delete(lesson.id)
    completed_modules.delete(lesson.course_module_id)
    self.course_completed = false
    save!
  end

  def progress
    @progress ||= course.lessons_count.positive? ? (completed_lessons.size / course.lessons_count.to_f * 100).floor : 0
  end

  def module_progress(course_module)
    @module_progress ||= {}
    return @module_progress[course_module.id] if @module_progress[course_module.id].present?

    finished_lessons_of_module = completed_lessons & course_module.lessons.map(&:id)
    @module_progress[course_module.id] =
      if course_module.lessons_count.positive?
        (finished_lessons_of_module.size / course_module.lessons_count.to_f * 100).floor
      else
        0
      end
  end

  def quiz_completed_for?(course_module)
    (course_module.quizzes.map(&:id) &
    quiz_answers_for(course_module).map(&:quiz_id)).size == course_module.quizzes_count
  end

  def correct_quiz_count_for(course_module)
    quiz_answers_for(course_module).filter(&:correct?).size
  end

  def incorrect_quiz_count_for(course_module)
    quiz_answers_for(course_module).filter(&:incorrect?).size
  end

  def skipped_quiz_count_for(course_module)
    quiz_answers_for(course_module).filter(&:skipped?).size
  end

  def score_earned_for(course_module)
    quiz_answers_for(course_module).map(&:score).reduce(:+) || 0
  end

  def delete_recorded_answers_for(course_module)
    quiz_answers_for(course_module).each(&:destroy)
  end

  def quiz_answers_for(course_module, eager_load_quiz: false)
    scope = quiz_answers.where(course_module_id: course_module.id)
    eager_load_quiz ? scope.includes(:quiz) : scope
  end

  def set_score!(score)
    self.score = score
    save!
  end

  def deadline_present?
    deadline_at.present?
  end
end
