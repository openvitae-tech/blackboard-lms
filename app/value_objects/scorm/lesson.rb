# frozen_string_literal: true

class Scorm::Lesson < ScormPackage::BaseLesson
  attr_reader :lesson

  def initialize(lesson)
    super()
    @lesson = lesson
  end

  def title
    lesson.title
  end

  def videos
    lesson.local_contents.map do |local_content|
      Scorm::Video.new(
        local_content.id,
        local_content.lang,
        get_video_url(local_content.id)
      )
    end
  end

  private

  def get_video_url(id)
    "http://127.0.0.1:3000/embeds/videos/#{id}"
  end
end
