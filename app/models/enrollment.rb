class Enrollment < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :user_id, uniqueness: { scope: :course_id }

  def set_progress!(module_id, lesson_id)
    self.current_module_id = module_id
    self.current_lesson_id = lesson_id
    self.save!
  end
end
