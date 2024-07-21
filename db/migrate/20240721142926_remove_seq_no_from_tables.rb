class RemoveSeqNoFromTables < ActiveRecord::Migration[7.1]
  def change
    remove_column :course_modules, :seq_no
    remove_column :lessons, :seq_no
    remove_column :quizzes, :seq_no
  end
end
