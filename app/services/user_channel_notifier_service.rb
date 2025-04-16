# frozen_string_literal: true

class UserChannelNotifierService
  include Singleton

  def notify_user(user, template: nil, parameters: nil)
    dispatch_job(user, template, parameters)
  end

  private

  def dispatch_job(user, template, parameters)
    case user.communication_channel
    when 'whatsapp'
      CommunicationChannels::SendWhatsappMessageJob.perform_async(user.phone, template, parameters)
    when 'sms'
      CommunicationChannels::SendSmsJob.perform_async(user.phone, parameters[:sms_variables_values],
                                                      parameters[:sms_message_id])
    end
  end
end
