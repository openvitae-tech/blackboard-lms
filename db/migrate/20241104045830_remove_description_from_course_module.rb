class RemoveDescriptionFromCourseModule < ActiveRecord::Migration[7.2]
  def change
    remove_column :course_modules, :description
  end
end
