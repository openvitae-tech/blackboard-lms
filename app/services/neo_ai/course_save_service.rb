# frozen_string_literal: true

module NeoAi
  class CourseSaveService
    def initialize(neo_ai_client)
      @neo_ai = neo_ai_client
    end

    def call(neo_ai_course_id)
      existing = Course.find_by(neo_ai_course_id: neo_ai_course_id)
      return existing if existing.present?

      data = @neo_ai.find_course(neo_ai_course_id)

      ActiveRecord::Base.transaction do
        course = Course.create!(
          neo_ai_course_id: neo_ai_course_id,
          title: data['title'],
          description: data['description'],
          visibility: :private
        )

        module_ids = (data['modules'] || []).map { |m| save_module(course, m).id }
        course.update!(course_modules_in_order: module_ids)

        course
      end
    end

    private

    def save_module(course, mod_data)
      course_module = course.course_modules.create!(title: mod_data['title'])
      lesson_ids = (mod_data['lessons'] || []).map { |l| save_lesson(course_module, l).id }
      course_module.update!(lessons_in_order: lesson_ids)
      course_module
    end

    def save_lesson(course_module, lesson_data)
      course_module.lessons.create!(
        title: lesson_data['title'],
        description: lesson_data['description'],
        duration: lesson_data['estimated_duration'].to_i,
        video_streaming_source: lesson_data['video_url']
      )
    end
  end
end
