class AddEnrollmentCount < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :enrollments_count, :integer, default: 0
    add_column :courses, :enrollments_count, :integer, default: 0
  end
end
