class CreateAssessments < ActiveRecord::Migration[8.0]
  def change
    create_table :assessments do |t|
      t.references :user, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true

      t.jsonb :questions, default: [], null: false      
      t.jsonb :responses, default: {}, null: false

      t.integer :status, default: 0, null: false      
      t.integer :current_question_index, default: 0
      t.integer :score, default: 0, null: false
      t.integer :attempt, default: 1, null: false

      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end

    add_index :assessments, :questions, using: :gin
    add_index :assessments, :responses, using: :gin
  end
end