# frozen_string_literal: true

module ScormService
  class Video < ScormPackage::BaseVideo
    attr_reader :id, :language, :video_url

    def initialize(id, language, video_url)
      super()
      @id = id
      @language = language
      @video_url = video_url
    end
  end
end
