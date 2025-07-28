class CreateProgramUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :program_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :program, null: false, foreign_key: true

      t.timestamps
      t.index [:user_id, :program_id], unique: true
    end
  end
end
