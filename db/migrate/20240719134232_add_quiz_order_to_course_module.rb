class AddQuizOrderToCourseModule < ActiveRecord::Migration[7.1]
  def change
    add_column :course_modules, :quizzes_in_order, :bigint, array: true, default: []
  end
end
