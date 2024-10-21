class AddCompletedModuelsToEnrollment < ActiveRecord::Migration[7.1]
  def change
    add_column :enrollments, :completed_modules, :bigint, array: true, default: []
    add_column :enrollments, :course_completed, :boolean, default: false
  end
end
