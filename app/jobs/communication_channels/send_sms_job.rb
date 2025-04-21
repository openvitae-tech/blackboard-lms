# frozen_string_literal: true

module CommunicationChannels
  class SendSmsJob < BaseJob
    def perform(template_id, mobile_number, variables_values)
      return if template_id.blank? || mobile_number.blank?

      whatsapp_channel = CommunicationChannels::Sms::MessagingChannel.new
      whatsapp_channel.send_message(mobile_number, variables_values, template_id)
    end
  end
end
