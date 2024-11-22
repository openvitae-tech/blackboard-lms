class AddScoreToEnrollments < ActiveRecord::Migration[7.2]
  def change
    add_column :enrollments, :score, :integer, default: 0
  end
end
