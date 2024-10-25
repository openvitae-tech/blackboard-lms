# frozen_string_literal: true

class LoginWithOtpService
  include Singleton

  def set_and_send_otp(mobile_number, user)
    user.set_otp!
    SendLoginOtpService.new(mobile_number, user).process if Rails.env.production?
  end

  def valid_otp?(user, otp)
    user.otp_generated_at > 5.minute.ago && user.authenticate_otp(otp)
  end
end
