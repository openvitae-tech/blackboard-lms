class CreateNotifications < ActiveRecord::Migration[7.1]
  def change
    create_table :notifications do |t|
      t.string :ntype
      t.string :text
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
