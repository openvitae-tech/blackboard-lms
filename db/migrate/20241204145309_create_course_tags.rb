class CreateCourseTags < ActiveRecord::Migration[7.2]
  def change
    create_table :courses_tags do |t|
      t.belongs_to :course, null: false
      t.belongs_to :tag, null: false

      t.timestamps
    end
  end
end
