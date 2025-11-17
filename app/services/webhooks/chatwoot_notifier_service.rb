# frozen_string_literal: true

module Webhooks
  class ChatwootNotifierService
    include Singleton
    include CommonsHelper

    def notify(params)
      return if params.empty?

      text = params.dig('conversation', 'messages').first['content']

      llm_response = Integrations::Llm::Api.llm_instance(provider: :openai).chat(text)
      response = create_request(params, llm_response.data)
      return if response.status == 200

      log_error_to_sentry(response.body)
    end

    private

    def create_request(params, llm_response)
      conversation_id = params.dig('conversation', 'id')
      account_id = Rails.application.credentials.dig(:chatwoot, :account_id)

      url = "https://app.chatwoot.com/api/v1/accounts/#{account_id}/conversations/#{conversation_id}/messages"
      headers = {
        'Content-Type' => 'application/json',
        'api_access_token' => Rails.application.credentials.dig(:chatwoot, :api_key)
      }
      body = {
        content: llm_response,
        message_type: 'outgoing'
      }

      Faraday.post(url, body.to_json, headers)
    end
  end
end
