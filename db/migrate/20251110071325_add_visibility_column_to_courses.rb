class AddVisibilityColumnToCourses < ActiveRecord::Migration[8.0]
  def up
    add_column :courses, :visibility, :string

    Course.update_all(visibility: "private")

    change_column_null :courses, :visibility, false
  end

  def down
    remove_column :courses, :visibility
  end
end
