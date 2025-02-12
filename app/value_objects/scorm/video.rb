# frozen_string_literal: true

class Scorm::Video < ScormPackage::BaseVideo
  def initialize(id, language, video_url)
    super()
    @id = id
    @language = language
    @video_url = video_url
  end

  def id
    @id
  end

  def language
    @language
  end

  def video_url
    @video_url
  end
end
