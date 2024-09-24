# frozen_string_literal: true

class AddIsPublishedToCourses < ActiveRecord::Migration[7.1]
  def change
    add_column :courses, :is_published, :boolean, default: false
  end
end
