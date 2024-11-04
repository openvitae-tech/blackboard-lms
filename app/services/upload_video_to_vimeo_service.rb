# frozen_string_literal: true

require 'uri'
require 'open-uri'
require 'tempfile'

class UploadVideoToVimeoService
  attr_reader :file

  def initialize(file)
    @file = file
  end

  def process
    response = generate_upload_url

    unless response.is_a?(Net::HTTPSuccess)
      log_error_to_sentry(response, "Failed to generate upload url")
      return
    end

    response_data = JSON.parse(response.body)

    upload_url = response_data.dig('upload', 'upload_link')
    vimeo_link = response_data['link']

    upload_response = upload_to_vimeo(upload_url)

    unless upload_response.is_a?(Net::HTTPSuccess)
      log_error_to_sentry(response, "Failed upload video to vimeo")
      return
    end

    file.update!(metadata: file.metadata.merge(url: vimeo_link))
    upload_response
  end

  private

  def generate_upload_url
    url = URI.parse('https://api.vimeo.com/me/videos')
    access_token = Rails.application.credentials.dig(:vimeo, :access_token)

    request = Net::HTTP::Post.new(url)
    request['Authorization'] = "bearer #{access_token}"
    request['Content-Type'] = 'application/json'
    request['Accept'] = 'application/vnd.vimeo.*+json;version=3.4'

    request.body = {
      upload: {
        approach: 'tus',
        size: file.byte_size
      },
      name: file.filename.to_s
    }.to_json

    Net::HTTP.start(url.hostname, url.port, use_ssl: true) { |http| http.request(request) }
  end

  def upload_to_vimeo(upload_url)
    Tempfile.create(['video', File.extname(file.filename.to_s)]) do |tempfile|
      tempfile.binmode
      tempfile.write(URI.open(@file.url, 'rb').read)
      tempfile.rewind
      url = URI.parse(upload_url)
      request = Net::HTTP::Patch.new(url)

      request['Tus-Resumable'] = '1.0.0'
      request['Upload-Offset'] = '0'
      request['Content-Type'] = 'application/offset+octet-stream'

      request.body = tempfile.read
      Net::HTTP.start(url.hostname, url.port, use_ssl: true) { |http| http.request(request) }
    end
  end

  def log_error_to_sentry(response, msg)
    Sentry.capture_message(msg, level: :error, extra: {
                             status: response.code,
                             body: response.body
                           })
  end
end
