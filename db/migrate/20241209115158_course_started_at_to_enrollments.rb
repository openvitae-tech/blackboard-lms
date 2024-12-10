class CourseStartedAtToEnrollments < ActiveRecord::Migration[7.2]
  def change
    add_column :enrollments, :course_started_at, :datetime, default: nil
  end
end
