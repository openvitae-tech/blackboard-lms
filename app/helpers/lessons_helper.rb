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

  def lesson_navigation_buttons(course, course_module, lesson)
    [
      {
        label: t("lesson.previous"),
        link: prev_lesson_path(course, course_module, lesson)
      },
      {
        label: t("lesson.next"),
        link: next_lesson_path(course, course_module, lesson)
      }
    ]
  end

  def is_lesson_completed(course_id, lesson_id)
    current_user.get_enrollment_for(current_user.courses.find(course_id)).completed_lessons.include? lesson_id
  end

  def is_current_lesson(lesson_id, current_lesson_id)
    lesson_id.to_s == current_lesson_id
  end

  def lesson_in_course_module?(course_module, lesson_id)
    course_module.lessons.pluck(:id).include?(lesson_id.to_i)
  end
end
