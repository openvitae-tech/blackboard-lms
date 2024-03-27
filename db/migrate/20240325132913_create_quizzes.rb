class CreateQuizzes < ActiveRecord::Migration[7.1]
  def change
    create_table :quizzes do |t|
      t.string :question
      t.string :quiz_type
      t.string :option_a
      t.string :option_b
      t.string :option_c
      t.string :option_d
      t.string :answer
      t.references :course_module, null: false, foreign_key: true

      t.timestamps
    end
  end
end
