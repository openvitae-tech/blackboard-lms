class AddQuizzCountToCourseModule < ActiveRecord::Migration[7.1]
  def change
    add_column :course_modules, :quizzes_count, :integer
  end
end
