class AddJsonDataToEvents < ActiveRecord::Migration[7.1]
  def change
    add_column :events, :data, :jsonb, null: false, default: {}
  end
end
