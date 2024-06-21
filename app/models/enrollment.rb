class Enrollment < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :course, counter_cache: true

  belongs_to :assigned_by, class_name: "User", foreign_key: "assigned_by_id", optional: true

  validates :user_id, uniqueness: { scope: :course_id }

  def set_progress!(module_id, lesson_id)
    self.current_module_id = module_id
    self.current_lesson_id = lesson_id
    self.completed_lessons.push(lesson_id)
    self.save!
  end

  # TODO: The id list on the completed_lessons needs a cleanup on deleting a lesson
  # The same applies to current_module_id and current_lesson_id attributes
  # A cleanup has to be performed on all the related enrollment records
end
