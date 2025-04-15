# frozen_string_literal: true

class UserChannelNotifierService
  include Singleton

  def notify_user(user, template, parameters = nil)
    dispatch_job(template, user, parameters)
  end

  private

  def dispatch_job(template, user, parameters)
    case user.communication_channel
    when 'whatsapp'
      CommunicationChannels::SendWhatsappMessageJob.perform_async(template, user.phone, parameters)
    end
  end
end
