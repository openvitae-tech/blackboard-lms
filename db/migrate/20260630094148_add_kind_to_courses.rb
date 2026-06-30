# frozen_string_literal: true

class AddKindToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :kind, :string, null: false, default: 'course'
    add_index :courses, :kind
  end
end
