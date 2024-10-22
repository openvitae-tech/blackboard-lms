# frozen_string_literal: true

class SendLoginOtpService
  attr_reader :mobile_number, :otp

  def initialize(mobile_number, user)
    @mobile_number = mobile_number
    @otp = user.otp
  end

  def process
    send_sms
  end

  private

  def send_sms
    url = URI.parse('https://control.msg91.com/api/v5/flow')
    request = build_request_url(url)
    Net::HTTP.start(url.hostname, url.port, use_ssl: true) { |http| http.request(request) }
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
end
