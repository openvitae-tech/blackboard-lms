# frozen_string_literal: true

class LoginWithOtpService
  include Singleton

  def set_otp!(user)
    user.set_otp!
  end

  def valid_otp?(user, otp)
    user.otp_generated_at > 5.minute.ago && user.otp.to_s == otp
  end
end
