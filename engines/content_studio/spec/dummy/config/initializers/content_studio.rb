# frozen_string_literal: true

# Point the API client at the dummy app itself so stub controllers serve fixture data.
# The dummy app boots on port 3001 (see config/puma.rb) to avoid clashing with the main app.
ContentStudio.base_url = 'http://localhost:3001'
ContentStudio.public_host = 'https://kosher-alienable-confusing.ngrok-free.dev'
ContentStudio.authorization_callback = ->(_user) { true }
