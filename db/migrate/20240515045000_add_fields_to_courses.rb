class AddFieldsToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :banner, :string
  end
end
