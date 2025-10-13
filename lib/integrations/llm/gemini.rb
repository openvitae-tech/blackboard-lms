# frozen_string_literal: true

module Integrations
  module Llm
    class Gemini < Api
      attr_accessor :model

      SUPPORTED_MODELS = %w[gemini-2.5-pro gemini-2.5-flash gemini-2.5-flash-lite].freeze
      DEFAULT_MODEL = 'gemini-2.5-flash'

      def initialize(model)
        super()

        validate_model(model)
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
      rescue StandardError => e
        log_error_to_sentry(e.message)
      end

      def log_error_to_sentry(msg)
        Sentry.capture_message(msg, level: :error)
      end

      def validate_model(model)
        return unless model && SUPPORTED_MODELS.exclude?(model)

        raise ArgumentError,
              "Unsupported model '#{model}' for gemini. Allowed: #{SUPPORTED_MODELS.join(', ')}"
      end
    end
  end
end
