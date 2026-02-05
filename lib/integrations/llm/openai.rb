# frozen_string_literal: true

module Integrations
  module Llm
    class Openai < Api
      include CommonsHelper

      attr_accessor :model

      SUPPORTED_MODELS = %w[gpt-4.1-nano gpt-4.1-mini	gpt-5-mini whisper-1].freeze
      DEFAULT_MODEL = 'gpt-4.1-nano'

      def initialize(model)
        super()

        validate_llm_model(model, SUPPORTED_MODELS)
        @model = model || DEFAULT_MODEL
      end

      def chat(prompt)
        ask(prompt)
      end

      def vector_search(prompt)
        perform_vector_search(prompt)
      end

      private

      def ask(prompt, file_path: nil, response_type: :text)
        service = RubyLLM.chat(model: model, provider: :openai)

        service = service.with_params(response_format: { type: 'json_object' }) if response_type == :json

        response = service.ask prompt, with: file_path

        response.content

        Result.ok(response.content)
      rescue StandardError => e
        log_error_to_sentry(e.message)

        Result.error(e.message)
      end

      def perform_vector_search(prompt)
        client = OpenAI::Client.new
        response = client.responses.create(
          parameters: {
            model: model,
            input: prompt,
            tools: [
              {
                'type' => 'file_search',
                'vector_store_ids' => [vector_store_id],
                'max_num_results' => 20
              }
            ],
            tool_choice: 'required',
            instructions: Instructions::Chatbot::INSTRUCTION
          }
        )

        Result.ok(extract_text(response))
      rescue StandardError => e
        log_error_to_sentry(e.message)
        Result.error(e.message)
      end

      def vector_store_id
        Rails.application.credentials.dig(:llm_token, :openai_vector_store_id)
      end

      def extract_text(resp)
        output = resp['output'] || []
        return '' if output.empty?

        output.flat_map do |item|
          (item['content'] || []).map { |c| c['text'] }
        end.compact.join("\n")
      end
    end
  end
end
