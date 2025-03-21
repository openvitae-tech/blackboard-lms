# frozen_string_literal: true

module LessonsHelper
  def get_video_iframe(local_content)
    video_url = local_content.video.blob.metadata['url']

    return if video_url.blank?

    vimeo_service = VimeoService.instance
    vendor_response = vimeo_service.resolve_video_url(video_url)
    vendor_response['html'] if vendor_response.key?('html')
  end

  def vimeo_upload_timed_out?(local_content)
    # TODO: Scope for refactoring
    # this checks upload to vimeo is pending or not. May be this is better renamed as upload_to_vimeo_pending?
    # also the status can be better named as vimeo_upload_status instead of status.
    if local_content.video.blob.metadata['url'].nil? && local_content.status == 'complete'
      true
    else
      local_content.status == 'pending' && local_content.video_published_at < 30.minutes.ago
    end
  end

  def get_local_content_lang(lesson)
    params[:lang].presence || default_local_content(lesson).lang
  end

  def default_local_content(lesson)
    default_language = lesson.local_contents.find_by(lang: LocalContent::DEFAULT_LANGUAGE.downcase)
    default_language.presence || lesson.local_contents.first
  end

  def lesson_navigation_buttons(course, course_module, lesson)
    [
      {
        label: t('lesson.previous'),
        link: prev_lesson_path(course, course_module, lesson)
      },
      {
        label: t('lesson.next'),
        link: next_lesson_path(course, course_module, lesson)
      }
    ]
  end

  def lesson_completed_by_user?(course_id, lesson_id)
    current_user.get_enrollment_for(current_user.courses.find(course_id)).completed_lessons.include? lesson_id
  end

  def current_lesson?(lesson_id, current_lesson_id)
    lesson_id.to_s == current_lesson_id
  end

  def lesson_in_course_module?(course_module, lesson_id)
    course_module.lessons.pluck(:id).include?(lesson_id.to_i)
  end

  def next_button_link(course, course_module, lesson)
    next_path = next_lesson_path(course, course_module, lesson)
    next_path.presence || course_path(course)
  end

  def lesson_delete_tooltip_message(course)
    if course.published?
      t('lesson.cannot_delete_published')
    else
      t('lesson.cannot_delete_enrolled')
    end
  end
end
