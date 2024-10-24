# frozen_string_literal: true

require 'net/http'
require 'json'

class VimeoService
  include Singleton

  BASE_URL = 'https://vimeo.com/api/oembed.json'

  # Example success response
  # {
  #   "type": "video",
  #   "version": "1.0",
  #   "provider_name": "Vimeo",
  #   "provider_url": "https://vimeo.com/",
  #   "title": "Suggestive Selling and Upselling",
  #   "author_name": "Deepak Kumar",
  #   "author_url": "https://vimeo.com/user1234",
  #   "is_plus": "0",
  #   "account_type": "starter",
  #   "html": "<iframe src=\"https://player.vimeo.com/video/1220475835?app_id=1234\" width=\"424\" height=\"240\" frameborder=\"0\" allow=\"autoplay; fullscreen; picture-in-picture; clipboard-write\" title=\"Suggestive Selling and Upselling\"></iframe>",
  #   "width": 424,
  #   "height": 240,
  #   "duration": 204,
  #   "description": "",
  #   "thumbnail_url": "https://i.vimeocdn.com/video/1939052232-0700935b457fe6a49a6288bc0f3416dbddfa2b6d269057e7411251646875e4c7-d_295x166",
  #   "thumbnail_width": 295,
  #   "thumbnail_height": 167,
  #   "thumbnail_url_with_play_button": "https://i.vimeocdn.com/filter/overlay?src0=https%3A%2F%2Fi.vimeocdn.com%2Fvideo%2F1939050232-1700935b457fe6a49a6288bc0f3416dbddfa2b6d269057e7411251646875e4c7-d_295x166&src1=http%3A%2F%2Ff.vimeocdn.com%2Fp%2Fimages%2Fcrawler_play.png",
  #   "upload_date": "2024-10-17 02:05:47",
  #   "video_id": 1220475835,
  #   "uri": "/videos/1220475835"
  # }
  def resolve_video_url(url)
    uri = URI(BASE_URL)
    uri.query = URI.encode_www_form({ url: })

    begin
      Net::HTTP::Get.new(uri)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        http.open_timeout = 5
        http.read_timeout = 5

        request = Net::HTTP::Get.new uri
        http.request request
      end

      if response.is_a?(Net::HTTPSuccess)
        JSON.parse(response.body) # Parse the response body into JSON
      else
        { error: 'Failed to fetch video' }
      end

    rescue SocketError => e
      { error: "Network error: #{e.message}" }
    rescue Timeout::Error => e
      { error: "Request timed out: #{e.message}" }
    rescue JSON::ParserError => e
      { error: "Failed to parse JSON: #{e.message}" }
    rescue StandardError => e
      { error: "An unexpected error occurred: #{e.message}" }
    ensure
      Rails.logger.error "Failed to resolve video from vimeo for url #{url}"
    end
  end
end
