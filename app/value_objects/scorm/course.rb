# frozen_string_literal: true
class Scorm::Course < ScormPackage::AbstractCourse
  attr_reader :course

  def initialize(course)
    @course = course
  end

  def title
    course.title
  end

  def description
    course.description
  end

  def course_modules
    course.course_modules.map do |course_module|
      Scorm::CourseModule.new(course_module)
    end
  end
end
