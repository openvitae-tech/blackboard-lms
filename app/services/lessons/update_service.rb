# frozen_string_literal: true

module Lessons
  class UpdateService
    include Singleton

    def update_lesson!(lesson, lesson_params)
      lesson.update!(lesson_params)
      PostProcessingService.instance.process_local_contents(lesson.local_contents)
    end
  end
end
