module ApplicationHelper

  VIMEO_REGEXP = /\Ahttps:\/\/vimeo\.com\/\d{9}?.*/
  VIMEO_BASE_URL = "https://player.vimeo.com/video/"

  def header_options(opts={})
    default_header_options = {
      title: nil,
      header_extended: false
    }

    default_header_options.merge!(opts)
  end

  def active(name, link)
    link == name ? "active" : ""
  end

  def vimeo_video_url(url)
    return "" unless url.match VIMEO_REGEXP
    video_id = URI(url).path.slice(1..9)
    "#{VIMEO_BASE_URL}#{video_id}"
  end

  def stats_builder(user_stats)
    [
      {
        icon: "shared/svg/book_open",
        value: user_stats.no_courses_enrolled.to_s,
        message: "Courses Enrolled"
      },
      {
        icon: "shared/svg/clock",
        value: duration_in_words(user_stats.total_time_spent),
        message: "Time Spent"
      },
      {
        icon: "shared/svg/file_text",
        value: user_stats.user_score,
        message: "Score Earned"
      }
    ]
  end

  def records_in_order(records, order)
    # sorts a list of records as per the order defined in order array
    # record in records must respond to :id
    h = {}
    order.each { |o| h[o] = nil }
    records.each  { |rec| h[rec.id] = rec }
    h.values
  end

  def mobile_view(&block)
    content_tag "div", class: "block md:hidden h-screen w-full", name: "mobile-view" do
      yield block
    end
  end
  def desktop_view(&block)
    content_tag "div", class: "hidden md:block h-screen w-full", name: "desktop-view" do
      yield block
    end
  end
end
