class CreateProgramCourses < ActiveRecord::Migration[8.0]
  def change
    create_table :program_courses do |t|
      t.references :program, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true

      t.timestamps

      t.index [:program_id, :course_id], unique: true
    end
  end
end
