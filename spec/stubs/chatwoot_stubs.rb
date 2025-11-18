# frozen_string_literal: true

def stub_chatwoot_api(conversation_id, llm_response, account_id)
  expected_body = { content: llm_response.data, message_type: 'outgoing' }.to_json

  stub_request(:post, "https://app.chatwoot.com/api/v1/accounts/#{account_id}/conversations/#{conversation_id}/messages")
    .with(
      body: expected_body,
      headers: {
        'Content-Type' => 'application/json',
        'api_access_token' => Rails.application.credentials.dig(:chatwoot, :api_key)
      }
    ).to_return(status: 200, body: 'ok')
end
