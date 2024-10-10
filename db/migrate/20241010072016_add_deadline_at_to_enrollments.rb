class AddDeadlineAtToEnrollments < ActiveRecord::Migration[7.1]
  def change
    add_column :enrollments, :deadline_at, :datetime, default: nil
  end
end
