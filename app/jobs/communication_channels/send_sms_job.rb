# frozen_string_literal: true

module CommunicationChannels
  class SendSmsJob < BaseJob
    def perform(template, mobile_number, country_code, variables_values)
      return if template.blank? || mobile_number.blank?

      config = {
        AVAILABLE_COUNTRIES[:india][:code] => {
          channel: CommunicationChannels::Sms::Fast2SmsMessagingChannel,
          recipient_format: ->(_, mobile_number) { mobile_number }
        },
        AVAILABLE_COUNTRIES[:uae][:code] => {
          channel: CommunicationChannels::Sms::Msg91MessagingChannel,
          recipient_format: ->(country_code, mobile_number) { "#{country_code}#{mobile_number}" }
        },
        AVAILABLE_COUNTRIES[:philippines][:code] => {
          channel: CommunicationChannels::Sms::Msg91MessagingChannel,
          recipient_format: ->(country_code, mobile_number) { "#{country_code}#{mobile_number}" }
        }
      }

      country_config = config[country_code]
      return unless country_config

      sms_channel = country_config[:channel].new
      recipient = country_config[:recipient_format].call(country_code, mobile_number)

      template_id = sms_channel.get_template_id(template)
      sms_channel.send_message(recipient, variables_values, template_id)
    end
  end
end
