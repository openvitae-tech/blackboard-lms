# frozen_string_literal: true

class SendLoginOtpService
  attr_reader :mobile_number, :otp

  def initialize(mobile_number, otp)
    @mobile_number = mobile_number
    @otp = otp
  end

  def process
    message_id = Rails.application.credentials.dig(:fast2sms, :message_id)
    sms_channel = CommunicationChannels::Sms::MessagingChannel.new
    sms_channel.send_message(mobile_number, otp, message_id)
  end
end
