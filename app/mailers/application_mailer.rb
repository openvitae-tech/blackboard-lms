class ApplicationMailer < ActionMailer::Base
  default from: Rails.application.credentials.dig(:app, :from_email)
  layout "mailer"
end
