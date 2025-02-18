class AddExpiresAtToScorms < ActiveRecord::Migration[7.2]
  def change
    add_column :scorms, :expires_at, :datetime

    Scorm.update_all(expires_at: 3.months.from_now)

    change_column_null :scorms, :expires_at, false
  end
end
