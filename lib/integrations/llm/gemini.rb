# frozen_string_literal: true

module Integrations
  module Llm
    class Gemini < Api
      include CommonsHelper

      attr_accessor :model

      SUPPORTED_MODELS = %w[gemini-2.5-pro gemini-2.5-flash gemini-2.5-flash-lite].freeze
      DEFAULT_MODEL = 'gemini-2.5-flash'

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
        service = RubyLLM.chat(model: model, provider: :gemini)

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
