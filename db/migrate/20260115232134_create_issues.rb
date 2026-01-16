class CreateIssues < ActiveRecord::Migration[8.0]
  def change
    create_table :issues do |t|
      t.references :user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.text :description, null: false

      t.timestamps
    end
  end
end
