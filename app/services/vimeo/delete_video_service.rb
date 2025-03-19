# frozen_string_literal: true

module Vimeo
  class DeleteVideoService
    include Singleton

    def delete_video(url)
      video_id = url.match(%r{vimeo\.com/(\d+)})[1]
      create_request(video_id)
    end

    private

    def create_request(video_id)
      url = URI.parse("https://api.vimeo.com/videos/#{video_id}")
      access_token = Rails.application.credentials.dig(:vimeo, :access_token)

      request = Net::HTTP::Delete.new(url)
      request['Authorization'] = "bearer #{access_token}"

      Net::HTTP.start(url.hostname, url.port, use_ssl: true) { |http| http.request(request) }
    end
  end
end
