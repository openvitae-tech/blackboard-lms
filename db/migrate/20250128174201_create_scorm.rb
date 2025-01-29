class CreateScorm < ActiveRecord::Migration[7.2]
  def change
    create_table :scorms do |t|
      t.string :token, null: false, index: { unique: true }
      t.boolean :is_valid, default: true
      t.references :learning_partner, index: { unique: true }, foreign_key: true, null: false
      t.timestamps
    end
  end
end
