class AddTimeSpentToEnrollments < ActiveRecord::Migration[7.1]
  def change
    add_column :enrollments, :time_spent, :integer, default: 0
  end
end
