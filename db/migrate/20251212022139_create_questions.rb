class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.text :content, null: false
      t.text :options, array: true, null: false, default: []
      t.text :answers, array: true, null: false, default: []
      t.boolean :is_verified, default: false
      t.boolean :is_gen_ai, default: false
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
