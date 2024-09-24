# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :name
      t.integer :partner_id
      t.integer :user_id
      t.timestamps
    end

    remove_column :events, :updated_at
  end
end
