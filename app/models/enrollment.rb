class Enrollment < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :course, counter_cache: true
  belongs_to :assigned_by, class_name: "User", foreign_key: "assigned_by_id", optional: true
  has_many :quiz_answers, dependent: :destroy

  validates :user_id, uniqueness: { scope: :course_id }

  def set_progress!(module_id, lesson_id)
    self.current_module_id = module_id
    self.current_lesson_id = lesson_id
    self.completed_lessons.push(lesson_id) unless self.completed_lessons.include? lesson_id
    self.save!
  end

  # TODO: The id list on the completed_lessons needs a cleanup on deleting a lesson
  # The same applies to current_module_id and current_lesson_id attributes
  # A cleanup has to be performed on all the related enrollment records
  def quiz_answered?(quiz)
    quiz_answers.exists?(quiz: quiz)
  end

  def get_answer(quiz)
    quiz_answers.where(quiz: quiz).first
  end
end
