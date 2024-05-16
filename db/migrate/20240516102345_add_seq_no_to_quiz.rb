class AddSeqNoToQuiz < ActiveRecord::Migration[7.1]
  def change
    add_column :quizzes, :seq_no, :integer
  end
end
