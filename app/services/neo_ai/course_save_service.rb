# frozen_string_literal: true

module NeoAi
  class CourseSaveService
    def initialize(neo_ai_client)
      @neo_ai = neo_ai_client
    end

    def call(neo_ai_course_id, learning_partner_id:)
      data = @neo_ai.find_course(neo_ai_course_id)

      ActiveRecord::Base.transaction do
        existing = Course.find_by(neo_ai_course_id: neo_ai_course_id)

        if existing
          sync_course(existing, data)
        else
          course = Course.create!(
            neo_ai_course_id: neo_ai_course_id,
            title: data['title'],
            description: data['description'],
            visibility: :private,
            learning_partner_id: learning_partner_id
          )
          attach_level_tag(course, data['level'])
          module_ids = (data['modules'] || []).map { |m| save_module(course, m).id }
          course.update!(course_modules_in_order: module_ids)
          course
        end
      end
    end

    private

    def sync_course(course, data)
      course.update!(title: data['title'], description: data['description'])

      api_modules = data['modules'] || []
      api_module_ids = api_modules.pluck('id').compact

      course.course_modules
            .where.not(neo_ai_module_id: nil)
            .where.not(neo_ai_module_id: api_module_ids)
            .destroy_all

      cs_module_ids = api_modules.map { |m| sync_module(course, m).id }
      bb_module_ids = course.course_modules.where(neo_ai_module_id: nil).order(:created_at).ids

      course.update!(course_modules_in_order: cs_module_ids + bb_module_ids)
      course
    end

    def sync_module(course, mod_data)
      course_module = course.course_modules.find_or_initialize_by(neo_ai_module_id: mod_data['id'])
      course_module.update!(title: mod_data['title'])

      api_lessons = mod_data['lessons'] || []
      api_lesson_ids = api_lessons.pluck('id').compact

      course_module.lessons
                   .where.not(neo_ai_lesson_id: nil)
                   .where.not(neo_ai_lesson_id: api_lesson_ids)
                   .destroy_all

      cs_lesson_ids = api_lessons.map { |l| sync_lesson(course_module, l).id }
      bb_lesson_ids = course_module.lessons.where(neo_ai_lesson_id: nil).order(:created_at).ids

      course_module.update!(lessons_in_order: cs_lesson_ids + bb_lesson_ids)
      course_module
    end

    def sync_lesson(course_module, lesson_data)
      lesson = course_module.lessons.find_or_initialize_by(neo_ai_lesson_id: lesson_data['id'])
      lesson.assign_attributes(
        title: lesson_data['title'],
        duration: lesson_data['estimated_duration'].to_i,
        video_streaming_source: lesson_data['video_url']
      )
      lesson.save!
      lesson.update!(rich_description: lesson_data['description']) if lesson_data['description'].present?
      enqueue_video_download(lesson) if lesson_data['video_url'].present?
      lesson
    end

    def attach_level_tag(course, level)
      return if level.blank?

      tag = Tag.find_or_create_by!(name: level, tag_type: :level)
      course.tags << tag
    end

    def save_module(course, mod_data)
      course_module = course.course_modules.create!(title: mod_data['title'], neo_ai_module_id: mod_data['id'])
      lesson_ids = (mod_data['lessons'] || []).map { |l| save_lesson(course_module, l).id }
      course_module.update!(lessons_in_order: lesson_ids)
      course_module
    end

    def save_lesson(course_module, lesson_data)
      lesson = course_module.lessons.create!(
        title: lesson_data['title'],
        duration: lesson_data['estimated_duration'].to_i,
        video_streaming_source: lesson_data['video_url'],
        neo_ai_lesson_id: lesson_data['id']
      )
      lesson.update!(rich_description: lesson_data['description']) if lesson_data['description'].present?
      enqueue_video_download(lesson) if lesson_data['video_url'].present?
      lesson
    end

    def enqueue_video_download(lesson)
      NeoAi::DownloadLessonVideoJob.perform_async(lesson.id)
    end
  end
end
