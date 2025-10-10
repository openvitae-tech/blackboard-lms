# frozen_string_literal: true

RubyLLM.configure do |config|
  config.gemini_api_key = Rails.application.credentials.dig(:llm_token, :gemini)

  # to connect ollama locally
  config.ollama_api_base = 'http://localhost:11434/v1'
end
