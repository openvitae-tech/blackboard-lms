# frozen_string_literal: true

ChannelMessageTemplates = Data.define do
  def course_assigned_template
    {
      sms: Rails.application.credentials.dig(:fast2sms, :template, :course_assigned),
      whatsapp: 'course_assigned'
    }
  end

  def course_enrolled_template
    {
      sms: Rails.application.credentials.dig(:fast2sms, :template, :course_enrolled),
      whatsapp: 'course_enrolled'
    }
  end

  def sms_otp_template
    {
      sms: Rails.application.credentials.dig(:fast2sms, :template, :otp)
    }
  end
end
