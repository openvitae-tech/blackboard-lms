# frozen_string_literal: true

class MoveModuleDescriptionToActionText < ActiveRecord::Migration[7.1]
  def change
    CourseModule.all.find_each do |m|
      m.update(rich_description: m.description)
    end
  end
end
