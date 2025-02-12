# frozen_string_literal: true
class Scorm::Course < ScormPackage::BaseCourse
  attr_reader :course

  def initialize(course)
    super()
    @course = course
  end

  def title
    course.title
  end

  def description
    course.description
  end

  def course_modules
    course.course_modules.includes(lessons: :local_contents).map do |course_module|
      Scorm::CourseModule.new(course_module)
    end
  end
end
