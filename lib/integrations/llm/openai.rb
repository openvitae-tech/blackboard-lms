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

      private

      def ask(prompt, file_path: nil, response_type: :text)
        service = RubyLLM.chat(model: model, provider: :openai)

        service = service.with_params(response_format: { type: 'json_object' }) if response_type == :json

        response = service.ask prompt, with: file_path

        response.content

        ResponseObject.ok(response.content)
      rescue StandardError => e
        log_error_to_sentry(e.message)

        ResponseObject.error(e.message)
      end
    end
  end
end
