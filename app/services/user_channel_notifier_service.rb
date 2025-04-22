# frozen_string_literal: true

class UserChannelNotifierService
  include Singleton

  def notify_user(user, template, parameters = nil)
    return if template.nil?

    user.communication_channels.each do |channel|
      dispatch_job(template, user, channel, parameters)
    end
  end

  private

  def dispatch_job(template, user, channel, parameters)
    case channel
    when 'whatsapp'
      CommunicationChannels::SendWhatsappMessageJob.perform_async(template[:whatsapp],
                                                                  user.phone, parameters)
    end
  end
end
