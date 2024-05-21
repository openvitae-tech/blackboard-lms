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
end
