# frozen_string_literal: true
class Scorm::Course < ScormPackage::BaseCourse
  attr_reader :course, :scorm_token

  def initialize(course, scorm_token)
    super()
    @course = course
    @scorm_token = scorm_token
  end

  def title
    course.title
  end

  def description
    course.description
  end

  def course_modules
    course.course_modules.includes(lessons: :local_contents).map do |course_module|
      Scorm::CourseModule.new(course_module, scorm_token)
    end
  end
end
