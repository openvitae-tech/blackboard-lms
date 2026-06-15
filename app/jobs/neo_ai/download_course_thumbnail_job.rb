# frozen_string_literal: true

require 'open-uri'

module NeoAi
  class DownloadCourseThumbnailJob < BaseJob
    def perform(course_id, thumbnail_url)
      course = Course.find_by(id: course_id)
      return if course.nil? || thumbnail_url.blank?

      with_tracing "course_id=#{course_id}" do
        URI.open(thumbnail_url, 'rb') do |file| # rubocop:disable Security/Open
          ext = File.extname(URI.parse(thumbnail_url).path).presence || '.jpg'
          course.banner.attach(
            io: file,
            filename: "course_#{course_id}_thumbnail#{ext}",
            content_type: Marcel::MimeType.for(file)
          )
        end
      end
    end
  end
end
