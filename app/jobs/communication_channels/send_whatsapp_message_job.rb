# frozen_string_literal: true

module CommunicationChannels
  class SendWhatsappMessageJob < BaseJob
    def perform(template_name, mobile_number, parameters)
      updated_mobile = "91#{mobile_number}"
      whatsapp_channel = CommunicationChannels::Whatsapp::MessagingChannel.new
      whatsapp_channel.send_message(updated_mobile, template_name, parameters)
    end
  end
end
