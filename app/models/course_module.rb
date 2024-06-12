class CourseModule < ApplicationRecord
  belongs_to :course, counter_cache: true
  has_many :lessons, dependent: :destroy
  has_many :quizzes, dependent: :destroy

  def duration
    lessons.map(&:duration).reduce(&:+)
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

  def first_module
    self.course.course_modules.where(seq_no: 1).first if self.course.course_modules_count > 0
  end

  def last_module
    self.course.course_modules.where(seq_no: self.course.course_modules_count).first if self.course.course_modules_count > 0
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
end
