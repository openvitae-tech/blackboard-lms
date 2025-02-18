# frozen_string_literal: true

class LoginWithOtpService
  include Singleton

  def set_and_send_otp(mobile_number, user)
    user.set_otp!
    SendLoginOtpService.new(mobile_number, password_decrypter(user.otp)).process if Rails.env.production?
  end

  def valid_otp?(user, otp)
    user.otp_generated_at > 5.minutes.ago && otp == password_decrypter(user.otp).to_s
  end

  private

  def password_decrypter(otp)
    password_verifier = Rails.application.message_verifier(Rails.application.credentials[:password_verifier])

    password_verifier.verify(otp)
  end
end
