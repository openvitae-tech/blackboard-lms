# frozen_string_literal: true

module CommunicationChannels
  class SendSmsJob < BaseJob
    def perform(template, mobile_number, country_code, variables_values)
      return if template.blank? || mobile_number.blank?

      if country_code == AVAILABLE_COUNTRIES[:uae][:code]
        sms_channel = CommunicationChannels::Sms::Msg91MessagingChannel.new
        recipient   = "#{country_code}#{mobile_number}"
      elsif country_code == AVAILABLE_COUNTRIES[:india][:code]
        sms_channel = CommunicationChannels::Sms::Fast2SmsMessagingChannel.new
        recipient   = mobile_number
      end

      template_id = sms_channel.get_template_id(template)
      sms_channel.send_message(recipient, variables_values, template_id)
    end
  end
end
