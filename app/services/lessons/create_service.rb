# frozen_string_literal: true

module Lessons
  class CreateService
    include Singleton

    def create_lesson!(lesson_params, course_module)
      lesson = course_module.lessons.create!(lesson_params)
      service = CourseManagementService.instance
      service.update_lesson_ordering!(course_module, lesson, :create)

      upload_to_vimeo(lesson) if Rails.env.production?
      lesson
    end

    private

    def upload_to_vimeo(lesson)
      lesson.local_contents.each do |item|
        blob = item.video.blob
        UploadVideoToVimeoJob.perform_async(blob.id, item.id)
      end
    end
  end
end
