# frozen_string_literal: true

module ApplicationHelper
  def header_options(opts = {})
    default_header_options = {
      title: nil,
      header_extended: false
    }

    default_header_options.merge!(opts)
  end

  def is_mobile_view_for_turbo?
    request.user_agent =~ /Mobile|webOS/
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

  def duration_in_words(duration)
    return "< 1 min" if duration < 60

    duration = (duration.to_f / 60).round * 60

    ["#{duration / 3600} #{duration / 3600 == 1 ? 'hr' : 'hrs'}",
     "#{duration / 60 % 60} #{duration / 60 % 60 == 1 ? 'min' : 'mins'}"]
      .select { |str| str =~ /^[1-9]/ }.join(" ")
  end
  
  def product_name
    Rails.application.credentials.org_name
  end

  def poling_interval
    Rails.env.local? ? 600 : 60
  end
  
end
