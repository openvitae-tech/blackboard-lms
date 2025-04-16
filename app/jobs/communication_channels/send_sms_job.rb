# frozen_string_literal: true

module CommunicationChannels
  class SendSmsJob < BaseJob
    def perform(mobile_number, variables_values, message_id)
      whatsapp_channel = CommunicationChannels::Sms::MessagingChannel.new
      whatsapp_channel.send_message(mobile_number, variables_values, message_id)
    end
  end
end
