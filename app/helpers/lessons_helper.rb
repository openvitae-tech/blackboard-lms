# frozen_string_literal: true

module LessonsHelper
  def get_video_iframe(video)
    video_url = video.blob.metadata['url']

    return unless video_url.present?

    vimeo_service = VimeoService.instance
    vendor_response = vimeo_service.resolve_video_url(video_url)
    vendor_response['html'] if vendor_response.has_key?('html')
  end
end
