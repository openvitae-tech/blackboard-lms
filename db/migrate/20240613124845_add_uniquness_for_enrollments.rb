class AddUniqunessForEnrollments < ActiveRecord::Migration[7.1]
  def change
    add_index :enrollments, [:user_id, :course_id], unique: true
  end
end
