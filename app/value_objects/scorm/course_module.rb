# frozen_string_literal: true

class Scorm::CourseModule < ScormPackage::BaseCourseModule
  attr_reader :course_module, :scorm_token

  def initialize(course_module, scorm_token)
    super()
    @course_module = course_module
    @scorm_token = scorm_token
  end

  def title
    course_module.title
  end

  def lessons
    course_module.lessons.map do |lesson|
      Scorm::Lesson.new(lesson, scorm_token)
    end
  end
end
