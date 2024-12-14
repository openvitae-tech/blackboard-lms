class DropTableNotifications < ActiveRecord::Migration[7.2]
  def up
    drop_table :notifications
  end

  def down
    # nothing to be done
  end
end
