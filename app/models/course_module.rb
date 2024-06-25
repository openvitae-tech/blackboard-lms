class CourseModule < ApplicationRecord
  belongs_to :course, counter_cache: true
  has_many :lessons, dependent: :destroy
  has_many :quizzes, dependent: :destroy

  def duration
    lessons.map(&:duration).reduce(&:+) || 0
  end

  def first_lesson
    lessons.where(seq_no: 1).first if lessons_count > 0
  end

  def last_lesson
    lessons.where(seq_no: lessons_count).first if lessons_count > 0
  end

  def next_lesson(current_lesson)
    if current_lesson.seq_no < lessons_count
      lessons.where(seq_no: current_lesson.seq_no + 1).first
    end
  end

  def prev_lesson(current_lesson)
    if current_lesson.seq_no > 1
      lessons.where(seq_no: current_lesson.seq_no - 1).first
    end
  end

  def next_module
    if self.seq_no < self.course.course_modules_count
      self.course.course_modules.where(seq_no: self.seq_no + 1).first
    end
  end

  def prev_module
    if self.seq_no > 1
      self.course.course_modules.where(seq_no: self.seq_no - 1).first
    end
  end

  def has_quiz?
    quizzes_count > 0
  end

  def first_quiz
    quizzes.where(seq_no: 1).first if quizzes_count > 0
  end

  def last_quiz
    quizzes.where(seq_no: quizzes_count).first if quizzes_count > 0
  end

  def next_quiz(current_quiz)
    if current_quiz.seq_no < quizzes_count
      quizzes.where(seq_no: current_quiz.seq_no + 1).first
    end
  end

  def prev_quiz(current_quiz)
    if current_quiz.seq_no > 1
      quizzes.where(seq_no: current_quiz.seq_no - 1).first
    end
  end
end
