class AddCourseModuleIdToQuizAnswers < ActiveRecord::Migration[7.2]
  def change
    add_column :quiz_answers, :course_module_id, :integer, null: false
  end
end
