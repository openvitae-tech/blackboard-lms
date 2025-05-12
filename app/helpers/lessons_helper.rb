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

  def active_lesson?(lesson_id, current_lesson_id)
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

  def lesson_accessible?(lesson, course, enrollment)
    return false unless enrollment

    completed_lessons = enrollment.completed_lessons

    return course.first_module&.first_lesson&.id == lesson.id if completed_lessons.empty?

    return true if completed_lessons.include?(lesson.id)

    ordered_lesson_ids = ordered_lesson_ids(course)

    last_completed_id = last_completed_lesson_id(completed_lessons, ordered_lesson_ids)
    first_incomplete_id = first_incomplete_lesson_id(completed_lessons, ordered_lesson_ids)

    lesson_index = ordered_lesson_ids.index(lesson.id)
    last_completed_index = ordered_lesson_ids.index(last_completed_id)

    lesson_index <= last_completed_index || lesson.id == first_incomplete_id
  end

  def first_incomplete_lesson_id(completed_lessons, ordered_lesson_ids)
    ordered_lesson_ids.find { |id| completed_lessons.exclude?(id) }
  end

  def last_completed_lesson_id(completed_lessons, ordered_lesson_ids)
    completed_lessons.max_by { |id| ordered_lesson_ids.index(id) }
  end

  def ordered_lesson_ids(course)
    course.course_modules.find(course.course_modules_in_order).flat_map(&:lessons_in_order)
  end

  def association_preloader(records = [], associations = {})
    ActiveRecord::Associations::Preloader.new(
      records:,
      associations:
    ).call
  end
end
