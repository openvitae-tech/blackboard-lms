class AddUniqueCompositeKeyForQuizAnswers < ActiveRecord::Migration[7.2]
  def change
    add_index :quiz_answers, [:quiz_id, :enrollment_id], unique: true
  end
end
