class CreatePrograms < ActiveRecord::Migration[8.0]
  def change
    create_table :programs do |t|
      t.string :name, null: false
      t.integer :courses_count, default: 0, null: false
      t.integer :users_count, default: 0, null: false

      t.references :learning_partner, null: false, foreign_key: true

      t.timestamps
    end
  end
end
