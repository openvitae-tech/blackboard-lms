# frozen_string_literal: true

ContentStudio.authorization_callback = lambda { |user|
  user.content_studio_creator? && user.learning_partner.content_studio_enabled?
}
ContentStudio.public_host = Rails.application.credentials.dig(:app, :base_url) || ContentStudio.public_host
