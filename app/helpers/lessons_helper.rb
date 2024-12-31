# frozen_string_literal: true

module LessonsHelper
  def get_video_iframe(local_content)
    video_url = local_content.video.blob.metadata['url']

    return unless video_url.present?

    vimeo_service = VimeoService.instance
    vendor_response = vimeo_service.resolve_video_url(video_url)
    vendor_response['html'] if vendor_response.has_key?('html')
  end

  def is_upload_pending(local_content)
    if local_content.video.blob.metadata['url'].nil? && local_content.status == "complete"
      true
    else
      local_content.status == "pending" && local_content.updated_at < 30.minutes.ago
    end
  end

  def get_local_content_lang(lesson)
    if params[:lang].present?
       params[:lang]
    else
     default_local_content(lesson).lang
    end
  end

  def default_local_content(lesson)
    default_language = lesson.local_contents.find_by(lang: LocalContent::DEFAULT_LANGUAGE.downcase)
    default_language.present? ? default_language : lesson.local_contents.first
  end
end
