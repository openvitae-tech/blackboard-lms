class CourseModule < ApplicationRecord
  belongs_to :course, counter_cache: true
  has_many :lessons, dependent: :destroy
  has_many :quizzes, dependent: :destroy

  def duration
    lessons.map(&:duration).reduce(&:+)
  end

  def next_lesson(current_lesson)
    if current_lesson.seq_no < lessons_count
      lessons.where(seq_no: current_lesson.seq_no + 1).first
    end
  end

  def prev_lesson(current_lesson)
    if current_lesson.seq_no > 0
      lessons.where(seq_no: current_lesson.seq_no - 1).first
    end
  end
end
