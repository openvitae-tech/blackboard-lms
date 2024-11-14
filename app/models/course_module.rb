# frozen_string_literal: true

class CourseModule < ApplicationRecord
  belongs_to :course, counter_cache: true
  has_many :lessons, dependent: :destroy
  has_many :quizzes, dependent: :destroy

  validates :title, presence: true, length: { minimum: 6, maximum: 255 }
  def duration
    lessons.map(&:duration).reduce(&:+) || 0
  end

  def first_lesson
    first_lesson_id = lessons_in_order.first
    lessons.find(first_lesson_id) if first_lesson_id.present?
  end

  def last_lesson
    last_lesson_id = lessons_in_order.last
    lessons.find(last_lesson_id) if last_lesson_id.present?
  end

  def next_lesson(current_lesson)
    index = lessons_in_order.find_index(current_lesson.id)

    return unless lessons_in_order[index + 1].present?

    lessons.find(lessons_in_order[index + 1])
  end

  def prev_lesson(current_lesson)
    index = lessons_in_order.find_index(current_lesson.id)

    return unless index.positive?

    lessons.find(lessons_in_order[index - 1])
  end

  def next_module
    course.next_module(self)
  end

  def prev_module
    course.prev_module(self)
  end

  def has_quiz?
    quizzes_count.positive?
  end

  def first_quiz
    first_quiz_id = quizzes_in_order.first
    quizzes.find(first_quiz_id) if first_quiz_id.present?
  end

  def last_quiz
    last_quiz_id = quizzes_in_order.last
    quizzes.find(last_quiz_id) if last_quiz_id.present?
  end

  def next_quiz(current_quiz)
    index = quizzes_in_order.find_index(current_quiz.id)

    return unless quizzes_in_order[index + 1].present?

    quizzes.find(quizzes_in_order[index + 1])
  end

  def prev_quiz(current_quiz)
    index = quizzes_in_order.find_index(current_quiz.id)

    return unless index.positive?

    quizzes.find(quizzes_in_order[index - 1])
  end
end
