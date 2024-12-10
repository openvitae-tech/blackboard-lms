class ReminderSendAtToEnrollments < ActiveRecord::Migration[7.2]
  def change
    add_column :enrollments, :reminder_send_at, :datetime, default: nil
  end
end
