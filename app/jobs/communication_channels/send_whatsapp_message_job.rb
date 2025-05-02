# frozen_string_literal: true

module CommunicationChannels
  class SendWhatsappMessageJob < BaseJob
    def perform(template, mobile_number, parameters)
      return unless mobile_number.present? || template.present?

      updated_mobile = "91#{mobile_number}"
      whatsapp_channel = CommunicationChannels::Whatsapp::MessagingChannel.new
      whatsapp_channel.send_message(updated_mobile, template, parameters)
    end
  end
end
