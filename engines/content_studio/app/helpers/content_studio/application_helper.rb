# frozen_string_literal: true

module ContentStudio
  module ApplicationHelper
    def format_duration(seconds)
      return '' unless seconds

      hours = seconds / 3600
      minutes = (seconds % 3600) / 60

      if hours.positive?
        minutes.positive? ? "#{hours} hr #{minutes} mins" : "#{hours} hr"
      else
        "#{minutes} mins"
      end
    end

    def studio_course_card(course, status)
      course_card_component(
        title: course.title,
        banner_url: course.thumbnail_url.presence || '/placeholder.gif',
        duration: format_duration(course.duration),
        modules_count: course.course_modules_count,
        enroll_count: course.enrollments_count || 0,
        categories: course.categories || [],
        rating: course.rating,
        progress: course.progress,
        badge: studio_badge(status)
      )
    end

    def lesson_status_label(status)
      case status
      when 'WAITING'     then 'Waiting'
      when 'verified'    then 'Verified'
      when 'video_ready' then 'Video ready'
      when 'in_process'  then 'In Process'
      else status.to_s.humanize
      end
    end

    def lesson_status_colorscheme(status)
      case status
      when 'verified'   then 'secondary'
      when 'in_process' then 'gold'
      else 'primary'
      end
    end

    def studio_badge(status)
      if status == 'to_be_verified'
        { label: 'Pending', bg_color: 'bg-danger', text_color: 'text-white' }
      else
        { label: status == 'verified' ? 'Verified' : 'Published' }
      end
    end
  end
end
