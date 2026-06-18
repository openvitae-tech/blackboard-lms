# frozen_string_literal: true

class CreateClassroomKits < ActiveRecord::Migration[8.0]
  def change
    create_table :classroom_kits do |t|
      t.string :title
      t.string :neo_ai_kit_id, null: false
      t.references :learning_partner, null: false, foreign_key: true

      t.timestamps
    end

    add_index :classroom_kits, :neo_ai_kit_id, unique: true
  end
end
