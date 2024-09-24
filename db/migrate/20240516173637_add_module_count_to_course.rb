# frozen_string_literal: true

class AddModuleCountToCourse < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :course_modules_count, :integer, default: 0
  end
end
