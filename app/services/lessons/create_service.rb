# frozen_string_literal: true

module Lessons
  class CreateService
    include Singleton

    def create_lesson!(lesson_params, course_module)
      lesson = course_module.lessons.create!(lesson_params)
      service = CourseManagementService.instance
      service.update_lesson_ordering!(course_module, lesson, :create)
      PostProcessingService.instance.process_local_contents(lesson.local_contents)
      # upload_to_vimeo(lesson) if APP_CONFIG.external_video_hosting?
      lesson
    end
  end
end
