# frozen_string_literal: true

# require_relative 'json_schema'

module Integrations
  module Llm
    class Gemini < Api
      include CommonsHelper
      include JsonSchema

      attr_accessor :model

      SUPPORTED_MODELS = %w[gemini-2.5-pro gemini-2.5-flash gemini-2.5-flash-lite].freeze
      DEFAULT_MODEL = 'gemini-2.5-flash'
      TRANSCRIPTION_PROMPT = "Generate timestamped transcription for the given audio file \
                        with output in json format. json should have start_at and end_at \
                        timestamps in milliseconds integers for each segment."

      def initialize(model)
        super()

        validate_llm_model(model, SUPPORTED_MODELS)
        @model = model || DEFAULT_MODEL
      end

      def chat(prompt)
        ask(prompt)
      end

      def generate_transcript(audio_file)
        ask(TRANSCRIPTION_PROMPT, file_path: audio_file, response_type: :json)
      end

      private

      def ask(prompt, file_path: nil, response_type: :text)
        service = RubyLLM.chat(model: model, provider: :gemini)
        service = service.with_schema(TranscriptSchema) if schema_class?(response_type)

        if response_type == :json || schema_class?(response_type)
          service = service.with_params(generationConfig: { response_mime_type: 'application/json' })
        end

        response = service.ask prompt, with: file_path

        response.content

        Result.ok(response.content)
      rescue StandardError => e
        log_error_to_sentry(e.message)

        Result.error(e.message)
      end

      def schema_class?(response_type)
        str_response_type = response_type.to_s.capitalize
        Object.const_defined?(str_response_type) && Object.const_get(str_response_type) < RubyLLM::Schema
      end
    end
  end
end
