class CreateTags < ActiveRecord::Migration[7.2]
  def change
    create_table :tags do |t|
      t.string "name", null: false, index: { unique: true }
      t.string "tag_type", null: false

      t.timestamps
    end
  end
end
