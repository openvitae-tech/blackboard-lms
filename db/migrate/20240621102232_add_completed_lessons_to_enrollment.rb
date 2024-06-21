class AddCompletedLessonsToEnrollment < ActiveRecord::Migration[7.1]
  def change
    add_column :enrollments, :completed_lessons, :bigint, array: true, default: []
  end
end
