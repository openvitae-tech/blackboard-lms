# frozen_string_literal: true

class AddQuizzCountToCourseModule < ActiveRecord::Migration[7.1]
  def change
    add_column :course_modules, :quizzes_count, :integer, default: 0
  end
end
