class AddModuleOrderToCourse < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :course_modules_in_order, :bigint, array: true, default: []
  end
end
