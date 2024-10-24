# frozen_string_literal: true

class SendLoginOtpService
  attr_reader :mobile_number, :otp

  def initialize(mobile_number, user)
    @mobile_number = mobile_number
    @otp = user.otp
  end

  def process
    response = send_sms
    log_error_to_sentry(response) unless response.is_a?(Net::HTTPSuccess)
    response
  end

  private

  def send_sms
    url = URI.parse(Rails.application.credentials.dig(:msg91, :url))
    request = build_request_url(url)
    Net::HTTP.start(url.hostname, url.port, use_ssl: true, read_timeout: 1) { |http| http.request(request) }
  end

  def build_request_url(url)
    request = Net::HTTP::Post.new(url)
    request['authkey'] = Rails.application.credentials.dig(:msg91, :auth_key)
    request['accept'] = 'application/json'
    request['Content-Type'] = 'application/json'

    request.body = {
      'template_id' => Rails.application.credentials.dig(:msg91, :template_id),
      'recipients' => [
        {
          'mobiles' => mobile_number
        }
      ],
      'OTP' => otp
    }.to_json

    request
  end

  def log_error_to_sentry(response)
    Sentry.capture_message('Failed to send OTP via SMS', level: :error, extra: {
                             status: response.code,
                             body: response.body
                           })
  end
end
