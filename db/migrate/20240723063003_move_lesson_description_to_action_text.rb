# frozen_string_literal: true

class MoveLessonDescriptionToActionText < ActiveRecord::Migration[7.1]
  def change
    Lesson.all.find_each do |lesson|
      lesson.update(rich_description: lesson.description)
    end
  end
end
