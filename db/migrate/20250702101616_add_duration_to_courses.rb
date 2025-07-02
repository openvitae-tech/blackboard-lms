class AddDurationToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :duration, :integer, default: 0
  end
end
