# frozen_string_literal: true

namespace :one_timer do
  desc 'Generate transcripts for existing videos'
  task generate_transcripts_for_existing_videos: :environment do
    Rails.logger.info 'Generating transcripts for existing videos'

    # Process coursewise so that if LLM rate limits, we can resume from the last course
    eng_lang = LocalContent::SUPPORTED_LANGUAGES[:english].downcase
    Course.find_each do |course|
      Rails.logger.info "Generating transcript for course: #{course.title}"
      course.course_modules.includes(lessons: :local_contents).find_each do |course_module|
        Rails.logger.info "Generating transcript for course module: #{course_module.title}"
        course_module.lessons.find_each do |lesson|
          local_content = lesson.local_contents.find_by(lang: eng_lang)
          next if local_content.blank? || local_content.transcripts.exists?

          Rails.logger.info "Generating transcript for Lesson: #{lesson.title}, LocalContent ID: #{local_content.id}"
          ExtractAndSaveAudioJob.perform_async(local_content.id)
        end
      end
    end
  end
end
