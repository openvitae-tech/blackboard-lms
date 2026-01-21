class AddNotNullToCurrentQuestionIndex < ActiveRecord::Migration[8.0]
  def change
    change_column_null :assessments, :current_question_index, false, 0
  end
end
