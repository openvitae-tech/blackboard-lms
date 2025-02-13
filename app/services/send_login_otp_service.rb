# frozen_string_literal: true

class SendLoginOtpService
  attr_reader :mobile_number, :otp

  def initialize(mobile_number, otp)
    @mobile_number = mobile_number
    @otp = otp
  end

  def process
    response = send_sms
    log_error_to_sentry(response) unless response.is_a?(Net::HTTPSuccess)
    response
  rescue
    log_general_error
  end

  private

  def send_sms
    url = URI.parse(Rails.application.credentials.dig(:fast2sms, :url))
    request = build_request_url(url)
    Net::HTTP.start(url.hostname, url.port, use_ssl: true, read_timeout: 1) { |http| http.request(request) }
  end

  def build_request_url(url)
    request = Net::HTTP::Post.new(url)
    request['authorization'] = Rails.application.credentials.dig(:fast2sms, :auth_key)
    request['Content-Type'] = 'application/json'

    request.set_form_data({
      "route" => "dlt",
      "sender_id" => Rails.application.credentials.dig(:fast2sms, :sender_id),
      "message" => Rails.application.credentials.dig(:fast2sms, :message_id),
      "variables_values" => otp,
      "numbers" => mobile_number
    })

    request
  end

  def log_error_to_sentry(response)
    Sentry.capture_message('Failed to send OTP via SMS', level: :error, extra: {
                             status: response.code,
                             body: response.body
                           })
  end

  def log_general_error
    Sentry.capture_message('An error occurred while sending OTP', level: :warning, extra: {
                             mobile_number: mobile_number
                           })
  end
end
