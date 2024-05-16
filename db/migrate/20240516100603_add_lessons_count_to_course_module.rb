class AddLessonsCountToCourseModule < ActiveRecord::Migration[7.1]
  def change
    add_column :course_modules, :lessons_count, :integer, default: 0
  end
end
