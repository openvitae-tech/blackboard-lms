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
        context = search_vector_store(prompt, client)

        return Result.ok(I18n.t('llm.response.idontknow')) if context.blank?

        response = client.responses.create(
          parameters: {
            model: model,
            input: [
              {
                role: 'system',
                content: <<~SYS
                  You MUST answer ONLY using the Context.
                  If the answer is not in the Context, reply exactly with: #{I18n.t('llm.response.idontknow')}.
                SYS
              },
              {
                role: 'system',
                content: "Context:\n\n#{context}"
              },
              {
                role: 'user',
                content: prompt
              }
            ]
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

      def search_vector_store(query, client)
        result = client.vector_stores.search(
          id: vector_store_id,
          parameters: {
            query: query,
            # Reduce max_num_results to 5 or 10 and uncomment ranking_options for less token consumption
            max_num_results: 20,
            # ranking_options: {
            #   score_threshold: 0.65,
            #   ranker: 'default-2024-11-15'
            # },
            rewrite_query: true
          }
        )

        chunks = result['data'] || []

        chunks.flat_map do |chunk|
          (chunk['content'] || []).map do |c|
            if c['text'].is_a?(Hash)
              c['text']['value']
            else
              c['text']
            end
          end
        end.compact.join("\n\n")
      end
    end
  end
end
