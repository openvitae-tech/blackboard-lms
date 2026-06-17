# frozen_string_literal: true

ContentStudio.authorization_callback = lambda { |user|
  user.content_studio_creator? && user.learning_partner.content_studio_enabled?
}
app_base_url = Rails.application.credentials.dig(:app, :base_url)
public_host = Rails.application.credentials.dig(:app, :public_host)
ContentStudio.base_url    = app_base_url || ContentStudio.base_url
ContentStudio.public_host = public_host || app_base_url || ContentStudio.public_host
