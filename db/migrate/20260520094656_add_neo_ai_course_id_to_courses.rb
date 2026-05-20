# frozen_string_literal: true

class AddNeoAiCourseIdToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :neo_ai_course_id, :string
    add_index :courses, :neo_ai_course_id, unique: true
  end
end
