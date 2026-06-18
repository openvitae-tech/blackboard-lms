# frozen_string_literal: true

module ContentStudio
  module ApplicationHelper
    def lesson_menu_items(course_id, lesson)
      [
        ViewComponent::MenuItem.new(
          label: 'Download Lesson',
          url: download_course_lesson_path(course_id, lesson.id),
          type: :link,
          options: { data: { turbo: false } },
          icon: 'arrow-down-tray'
        ),
        ViewComponent::MenuItem.new(
          label: 'Delete Lesson',
          url: alert_modal_path(
            title: t('alert.title', resource_name: 'lesson'),
            description: t('alert.description', label: lesson.title, resource_name: 'lesson'),
            action_path: destroy_course_lesson_path(course_id, lesson.id),
            method: :delete
          ),
          type: :link,
          extra_classes: 'text-danger',
          options: { data: { turbo_frame: 'modal' } },
          icon: 'trash'
        )
      ]
    end

    def format_scene_duration(seconds)
      return '0.00' if seconds.nil? || seconds <= 0

      total = seconds.to_i
      format('%<mins>d.%<secs>02d', mins: total / 60, secs: total % 60)
    end

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

    def template_card(template, selected: false)
      border_class = selected ? 'border-2 border-primary' : 'border border-line-colour'
      content_tag(:label,
                  class: 'cursor-pointer block',
                  data: { action: 'click->template-selector#select' }) do
        radio = tag.input(type: 'radio', name: 'template_id', value: template.id,
                          class: 'sr-only',
                          data: { template_selector_target: 'radio',
                                  thumbnail_url: template.thumbnail_url.to_s },
                          checked: selected)
        card_inner = if template.thumbnail_url.present?
                       image_tag(template.thumbnail_url,
                                 alt: template.name,
                                 class: 'w-full h-full object-cover')
                     else
                       placeholder_class = 'w-full h-full bg-primary-light-50 flex items-center ' \
                                           'justify-center general-text-sm-normal text-letter-color-light'
                       content_tag(:div, template.name, class: placeholder_class)
                     end
        card = content_tag(:div, card_inner,
                           class: "rounded-xl overflow-hidden w-72 aspect-video #{border_class}",
                           data: { template_selector_target: 'card' })
        radio + card
      end
    end

    def studio_course_card(course, _status)
      card = course_card_component(
        title: course.title,
        banner_url: course.thumbnail_url.presence,
        duration: format_duration(course.duration),
        modules_count: course.course_modules_count,
        enroll_count: course.enrollments_count || 0,
        categories: course.categories || [],
        rating: course.rating,
        progress: course.progress,
        badge: studio_badge(course.level),
        type_tag: { label: 'Course', bg_color: 'bg-primary-light-200', text_color: 'text-letter-color' }
      )
      link_to(card, course_structure_path(id: course.id), class: 'block')
    end

    def studio_kit_card(kit)
      card = course_card_component(
        title: kit.title.presence || 'Untitled Kit',
        banner_url: kit.thumbnail_url.presence,
        modules_count: kit.doc_count || 0,
        modules_label: 'Document',
        categories: [],
        type_tag: { label: 'Classroom Kit', bg_color: 'bg-secondary-light-200', text_color: 'text-letter-color' }
      )
      link_to(card, kit_structure_path(id: kit.id), class: 'block')
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

    def studio_badge(level)
      return nil if level.blank?

      { label: level, bg_color: 'bg-secondary', text_color: 'text-primary-dark' }
    end
  end
end
