# frozen_string_literal: true

ContentStudio.authorization_callback = ->(user) { user.privileged_user? }
ContentStudio.public_host = Rails.application.credentials.dig(:app, :base_url) || ContentStudio.public_host
