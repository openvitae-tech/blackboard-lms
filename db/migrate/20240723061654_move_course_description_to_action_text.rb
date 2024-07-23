class MoveCourseDescriptionToActionText < ActiveRecord::Migration[7.1]
  def change
    Course.all.find_each do |course|
      course.update(rich_description: course.description)
    end
  end
end
