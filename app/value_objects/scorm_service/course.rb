# frozen_string_literal: true

module ScormService
  class Course < ScormPackage::BaseCourse
    attr_reader :course, :scorm_token

    def initialize(course, scorm_token)
      super()
      @course = course
      @scorm_token = scorm_token
    end

    delegate :title, to: :course

    delegate :description, to: :course

    def course_modules
      course.course_modules.includes(lessons: :local_contents).map do |course_module|
        ScormService::CourseModule.new(course_module, scorm_token)
      end
    end
  end
end
