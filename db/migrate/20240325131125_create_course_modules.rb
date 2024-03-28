class CreateCourseModules < ActiveRecord::Migration[7.1]
  def change
    create_table :course_modules do |t|
      t.string :title
      t.text :description
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
