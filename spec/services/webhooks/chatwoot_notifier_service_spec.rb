# frozen_string_literal: true

RSpec.describe Webhooks::ChatwootNotifierService, type: :service do
  subject(:service) { described_class.instance }

  let(:incoming_text) { 'Hello from user' }

  describe '#notify' do
    before do
      @params = {
        'conversation' => {
          'id' => '999',
          'messages' => [
            { 'content' => incoming_text }
          ]
        }
      }
    end

    it 'sends llm response to chatwoot' do
      llm_response = double(data: 'ai-generated-response', ok?: true) # rubocop:disable RSpec/VerifiedDoubles
      llm_instance = instance_double('LlmInstance') # rubocop:disable RSpec/VerifiedDoubleReference
      account_id = Rails.application.credentials.dig(:chatwoot, :account_id)

      stub_chatwoot_api(999, llm_response, account_id)

      allow(Integrations::Llm::Api).to receive(:llm_instance).with(provider: :openai).and_return(llm_instance)
      allow(llm_instance).to receive(:vector_search).with(incoming_text).and_return(llm_response)

      expected_url = "https://app.chatwoot.com/api/v1/accounts/#{account_id}/conversations/999/messages"
      expected_body = { content: llm_response.data, message_type: 'outgoing' }.to_json
      expected_headers = {
        'Content-Type' => 'application/json',
        'api_access_token' => Rails.application.credentials.dig(:chatwoot, :api_key)
      }

      service.notify(@params)

      expect(Integrations::Llm::Api).to have_received(:llm_instance).with(provider: :openai)
      expect(a_request(:post, expected_url)
        .with(body: expected_body, headers: expected_headers)).to have_been_made.once
    end

    it 'when Chatwoot responds with non-200' do
      llm_instance = instance_double('LlmInstance') # rubocop:disable RSpec/VerifiedDoubleReference
      llm_response = double(data: 'ai-generated-response', ok?: true) # rubocop:disable RSpec/VerifiedDoubles

      allow(Integrations::Llm::Api).to receive(:llm_instance).with(provider: :openai).and_return(llm_instance)
      allow(llm_instance).to receive(:vector_search).with(incoming_text).and_return(llm_response)

      account_id = Rails.application.credentials.dig(:chatwoot, :account_id)
      stub_request(:post, "https://app.chatwoot.com/api/v1/accounts/#{account_id}/conversations/999/messages")
        .to_return(status: 500, body: 'something went wrong')

      allow(service).to receive(:log_error_to_sentry)

      service.notify(@params)
      expect(service).to have_received(:log_error_to_sentry).with('something went wrong')
    end
  end
end
