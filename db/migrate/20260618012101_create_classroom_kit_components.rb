class CreateClassroomKitComponents < ActiveRecord::Migration[8.0]
  def change
    create_table :classroom_kit_components do |t|
      t.references :classroom_kit, null: false, foreign_key: true
      t.string :neo_ai_component_id, null: false
      t.string :component_type, null: false
      t.string :title

      t.timestamps
    end

    add_index :classroom_kit_components, :neo_ai_component_id, unique: true
  end
end
