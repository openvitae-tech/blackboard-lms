# frozen_string_literal: true

class UserChannelNotifierService
  include Singleton

  def notify_user(user, template, parameters = nil)
    return if template.nil?

    user.communication_channels.each do |channel|
      dispatch_job(template, user, channel, parameters)
    end
  end

  def notify_via_sms(template, country_code, phone, parameters)
    CommunicationChannels::SendSmsJob.perform_async(
      template[:sms].as_json, phone, country_code, parameters[:sms_variables_values]
    )
  end

  def notify_via_whatsapp(template, phone, parameters)
    CommunicationChannels::SendWhatsappMessageJob.perform_async(template[:whatsapp], phone, parameters)
  end

  private

  def dispatch_job(template, user, channel, parameters)
    case channel
    when 'whatsapp'
      notify_via_whatsapp(template, user.phone, parameters)
    when 'sms'
      notify_via_sms(template, user.country_code, user.phone, parameters)
    end
  end
end
