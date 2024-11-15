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

  def stats_builder(user_stats)
    [
      {
        icon: 'shared/svg/book_open',
        value: user_stats.no_courses_enrolled.to_s,
        message: 'Courses Enrolled'
      },
      {
        icon: 'shared/svg/clock',
        value: duration_in_words(user_stats.total_time_spent),
        message: 'Time Spent'
      },
      {
        icon: 'shared/svg/file_text',
        value: user_stats.user_score,
        message: 'Score Earned'
      }
    ]
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

  def selected_language
    LocalContent::SUPPORTED_LANGUAGES[@local_content.lang.to_sym]
  end

  def language_options
    LocalContent::SUPPORTED_LANGUAGES.invert.to_a
  end

  def letter_avatar(user)
    (user.name || 'U')[0]
  end

  def submit_label_for(resource)
    resource.persisted? ? "Update" : "Create"
  end

  def sidebar_active(page)
    "item-selected" if page == controller_name
  end
end
