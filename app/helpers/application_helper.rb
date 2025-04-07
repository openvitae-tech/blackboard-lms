# frozen_string_literal: true

module ApplicationHelper
  def header_options(opts = {})
    default_header_options = {
      title: nil,
      header_extended: false
    }

    default_header_options.merge!(opts)
  end

  def active(name, link)
    link == name ? 'active' : ''
  end

  def records_in_order(records, order)
    # sorts a list of records as per the order defined in order array
    # record in records must respond to :id
    h = {}
    order.each { |o| h[o] = nil }
    records.each { |rec| h[rec.id] = rec }
    h.values
  end

  def mobile_view(&block)
    content_tag 'div', class: 'block md:hidden h-screen w-full', name: 'mobile-view' do
      yield block
    end
  end

  def desktop_view(&block)
    content_tag 'div', class: 'hidden md:block h-screen w-full', name: 'desktop-view' do
      yield block
    end
  end

  def supported_languages(lesson)
    languages = lesson.local_contents.map(&:lang).append(LocalContent::DEFAULT_LANGUAGE).map(&:to_sym)
    LocalContent::SUPPORTED_LANGUAGES.slice(*languages)
  end

  def selected_language(local_content)
    LocalContent::SUPPORTED_LANGUAGES[local_content.lang.to_sym]
  end

  def language_options
    LocalContent::SUPPORTED_LANGUAGES.invert.to_a
  end

  def letter_avatar(user)
    (user.name || 'U')[0]
  end

  def submit_label_for(resource)
    resource.persisted? ? 'Update' : 'Create'
  end

  def sidebar_active(page)
    'item-selected' if page == controller_name
  end

  def duration_in_words(duration)
    return '< 1 min' if duration < 60

    duration = (duration.to_f / 60).round * 60

    ["#{duration / 3600} #{duration / 3600 == 1 ? 'hr' : 'hrs'}",
     "#{duration / 60 % 60} #{duration / 60 % 60 == 1 ? 'min' : 'mins'}"]
      .grep(/^[1-9]/).join(' ')
  end

  def product_name
    Rails.application.credentials.org_name
  end

  def poling_interval
    Rails.env.local? ? 600 : 60
  end

  def pending_notifications
    NotificationService.instance.pending_notification_for(current_user)
  end

  def days_remaining(deadline_date)
    days = (deadline_date.to_date - Date.current).to_i
    days.positive? ? days : 0
  end

  def feature_enabled?(feature_flag)
    # user feature flags from constants.rb
    feature_flag || Rails.env.local?
  end

  # apply classes conditionally on a content tag
  # Example: content_tag(:div, class: class_names("flex", 'disabled': !permitted?))
  def class_names(*classes)
    class_array = [(classes.shift if classes.first.is_a? String), classes.first.select { |_, v| v }.keys]
    class_array.compact.join(' ')
  end

  def text_with_paragraph(text)
    return '' if text.blank?

    safe_join(text.split("\n").map { |para| content_tag(:p, para, class: 'my-2') })
  end

  def show_notification_bar?
    false
  end
end
