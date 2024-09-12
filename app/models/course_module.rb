class CourseModule < ApplicationRecord
  belongs_to :course, counter_cache: true
  has_many :lessons, dependent: :destroy
  has_many :quizzes, dependent: :destroy

  has_rich_text :rich_description

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

    if lessons_in_order[index + 1].present?
      lessons.find(lessons_in_order[index + 1])
    end
  end

  def prev_lesson(current_lesson)
    index = lessons_in_order.find_index(current_lesson.id)

    if index > 0
      lessons.find(lessons_in_order[index - 1])
    end
  end

  def next_module
    self.course.next_module(self)
  end

  def prev_module
    self.course.prev_module(self)
  end

  def has_quiz?
    quizzes_count > 0
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

    if quizzes_in_order[index + 1].present?
      quizzes.find(quizzes_in_order[index + 1])
    end
  end

  def prev_quiz(current_quiz)
    index = quizzes_in_order.find_index(current_quiz.id)

    if index > 0
      quizzes.find(quizzes_in_order[index - 1])
    end
  end

  def progress
    @temp_progress ||= rand(0..100)
    @temp_progress > 50 ? @temp_progress : 0
  end
end
