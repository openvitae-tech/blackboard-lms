# frozen_string_literal: true

class Scorm::Lesson < ScormPackage::BaseLesson
  attr_reader :lesson, :scorm_token

  def initialize(lesson, scorm_token)
    super()
    @lesson = lesson
    @scorm_token = scorm_token
  end

  def title
    lesson.title
  end

  def videos
    lesson.local_contents.map do |local_content|
      Scorm::Video.new(
        local_content.id,
        local_content.lang,
        get_video_url(local_content.id, scorm_token)
      )
    end
  end

  private

  def get_video_url(id, scorm_token)
    "#{Rails.application.credentials.dig(:app, :base_url)}/embeds/videos/#{id}?token=#{scorm_token}"
  end
end
