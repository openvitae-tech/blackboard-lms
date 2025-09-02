# frozen_string_literal: true

class ChannelMessageTemplates
  include Singleton

  def course_assigned_template
    {
      sms: {
        fast2_sms: Rails.application.credentials.dig(:fast2sms, :template, :course_assigned),
        msg91: Rails.application.credentials.dig(:msg91, :template, :course_assigned)
      },
      whatsapp: 'course_assigned'
    }
  end

  def course_enrolled_template
    {
      sms: {
        fast2_sms: Rails.application.credentials.dig(:fast2sms, :template, :course_enrolled),
        msg91: Rails.application.credentials.dig(:msg91, :template, :course_enrolled)
      },
      whatsapp: 'course_enrolled'
    }
  end

  def otp_template
    {
      sms: {
        fast2_sms: Rails.application.credentials.dig(:fast2sms, :template, :otp),
        msg91: Rails.application.credentials.dig(:msg91, :template, :otp)
      }
    }
  end

  def welcome_template
    {
      sms: {
        fast2_sms: Rails.application.credentials.dig(:fast2sms, :template, :welcome),
        msg91: Rails.application.credentials.dig(:msg91, :template, :welcome)
      },
      whatsapp: 'welcome'
    }
  end

  def b2c_user_verify_template
    {
      sms: {
        fast2_sms: Rails.application.credentials.dig(:fast2sms, :template, :b2c_verify)
      }
    }
  end
end
