# frozen_string_literal: true

OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.dig(:llm_token, :openai)
  config.log_errors = true
end
