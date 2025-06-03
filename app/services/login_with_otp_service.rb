# frozen_string_literal: true

class LoginWithOtpService
  include Singleton

  def generate_and_send_otp(user)
    user.set_otp!

    return unless Rails.env.production?

    parameters = { sms_variables_values: password_decrypter(user.otp) }
    service = UserChannelNotifierService.instance
    service.notify_user(user, ChannelMessageTemplates.new.sms_otp_template, parameters)
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
