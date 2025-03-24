# frozen_string_literal: true

module ScormService
  class CourseModule < ScormPackage::BaseCourseModule
    attr_reader :course_module, :scorm_token

    def initialize(course_module, scorm_token)
      super()
      @course_module = course_module
      @scorm_token = scorm_token
    end

    delegate :title, to: :course_module
    def lessons
      course_module.lessons.map do |lesson|
        ScormService::Lesson.new(lesson, scorm_token)
      end
    end
  end
end
