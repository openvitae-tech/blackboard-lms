class AddUniqueIndexToIssues < ActiveRecord::Migration[8.0]
  def change
    add_index :issues, [:user_id, :question_id], unique: true
  end
end
