class CourseModule < ApplicationRecord
  belongs_to :course
  has_many :lessons, dependent: :destroy
  has_many :quizzes, dependent: :destroy

  def duration
    lessons.map(&:duration).reduce(&:+)
  end
end
