class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name
      t.integer :partner_id
      t.integer :user_id

      t.created_at
    end
  end
end
