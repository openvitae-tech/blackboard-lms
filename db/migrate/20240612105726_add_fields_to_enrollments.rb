class AddFieldsToEnrollments < ActiveRecord::Migration[7.1]
  def change
    add_column :enrollments, :current_module_id, :integer
    add_column :enrollments, :current_lesson_id, :integer
  end
end
