# frozen_string_literal: true

class Scorm::Lesson < ScormEngine::Lesson
  attr_reader :lesson

  def initialize(lesson)
    @lesson = lesson
  end

  def title
    lesson.title
  end

  def videos
    lesson.local_contents.map do |local_content|
      {
        language: local_content.lang,
        video_url: local_content.video.blob&.metadata['url']&.gsub("https://vimeo.com/", "https://player.vimeo.com/video/")
      }
    end
  end
end
