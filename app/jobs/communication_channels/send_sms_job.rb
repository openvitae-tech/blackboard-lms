# frozen_string_literal: true

module CommunicationChannels
  class SendSmsJob < BaseJob
    def perform(template, mobile_number, country_code, variables_values)
      return if template.blank? || mobile_number.blank?

      country_config = AVAILABLE_COUNTRIES.values.find { |c| c[:code] == country_code }
      return if country_config.blank?

      sms_channel_class, recipient = load_channel_and_recipient(country_config[:sms_channel], mobile_number,
                                                                country_code)

      sms_channel = sms_channel_class.new
      template_id = sms_channel.get_template_id(template)
      sms_channel.send_message(recipient, variables_values, template_id)
    end

    private

    def load_channel_and_recipient(channel, mobile_number, country_code)
      case channel
      when 'fast2sms'
        [CommunicationChannels::Sms::Fast2SmsMessagingChannel, mobile_number]
      when 'msg91'
        [CommunicationChannels::Sms::Msg91MessagingChannel, "#{country_code}#{mobile_number}"]
      end
    end
  end
end
