class AddExpiresAtToScorms < ActiveRecord::Migration[7.2]
  def change
    add_column :scorms, :expires_at, :datetime, null: false
  end
end
