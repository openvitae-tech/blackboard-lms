# frozen_string_literal: true

require 'open-uri'

module NeoAi
  class DownloadLessonVideoJob < BaseJob
    def perform(lesson_id)
      lesson = Lesson.find_by(id: lesson_id)
      return if lesson.nil? || lesson.video_streaming_source.blank?

      with_tracing "lesson_id=#{lesson_id}" do
        lesson.local_contents.destroy_all

        URI.open(lesson.video_streaming_source, 'rb') do |file| # rubocop:disable Security/Open
          blob = ActiveStorage::Blob.create_and_upload!(
            io: file,
            filename: 'video.mp4',
            content_type: 'video/mp4'
          )

          Lessons::UpdateService.instance.update_lesson!(
            lesson,
            local_contents_attributes: [{ blob_id: blob.id, lang: LocalContent::DEFAULT_LANGUAGE.downcase }]
          )
        end
      end
    end
  end
end
