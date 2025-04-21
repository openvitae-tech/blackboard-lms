# frozen_string_literal: true

class UserChannelNotifierService
  include Singleton

  def notify_user(user, template_identifier, parameters = nil)
    template = message_template(template_identifier)

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

  def message_template(template_identifier)
    case template_identifier
    when 'course_assigned_template'
      { sms: Rails.application.credentials.dig(:fast2sms, :template, :course_assigned), whatsapp: 'course_assigned' }
    when 'course_enrolled_template'
      { sms: Rails.application.credentials.dig(:fast2sms, :template, :course_enrolled), whatsapp: 'course_enrolled' }
    end
  end
end
