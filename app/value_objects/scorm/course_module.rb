# frozen_string_literal: true

class Scorm::CourseModule < ScormPackage::AbstractCourseModule
  attr_reader :course_module

  def initialize(course_module)
    @course_module = course_module
  end

  def title
    course_module.title
  end

  def lessons
    course_module.lessons.map do |lesson|
      Scorm::Lesson.new(lesson)
    end
  end
end
