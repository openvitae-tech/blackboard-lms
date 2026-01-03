# frozen_string_literal: true

module Integrations
  module Llm
    class Gemini < Api
      include CommonsHelper
      include JsonSchema

      attr_accessor :model

      SUPPORTED_MODELS = %w[gemini-2.5-pro gemini-2.5-flash gemini-2.5-flash-lite].freeze
      DEFAULT_MODEL = 'gemini-2.5-flash'
      TRANSCRIPTION_PROMPT = 'Generate timestamped transcription for the given audio file'
      QUIZ_GENERATION_PROMPT = 'You are an expert quiz generator. Given the following content, \
        create #COUNT quizzes that test comprehension, key concepts, and critical thinking.\
        Each quiz should have one question, four options, and indicate the correct answer. \
        Keep questions clear and concise. Avoid references to the source material.'
      QUESTION_GENERATION_PROMPT = 'You are an expert in question generation. Given the following content, \
        and attached files create #COUNT questions that test comprehension, key concepts, and critical thinking.\
        Each question can have mininum 2 options and maximum 5 options to select. \
        Some questions can have one answer while some can have multiple answers. \
        Keep questions clear and concise. Avoid references to the source material.'
      RESPONSE_TYPES = %i[text json].freeze

      def initialize(model)
        super()

        validate_llm_model(model, SUPPORTED_MODELS)
        @model = model || DEFAULT_MODEL
      end

      def chat(prompt)
        ask(prompt)
      end

      def generate_transcript(audio_file)
        ask(TRANSCRIPTION_PROMPT, file_path: audio_file, response_type: 'TranscriptSchema')
      end

      def generate_quiz(count, transcripts)
        prompt = "#{QUIZ_GENERATION_PROMPT.gsub('#COUNT', count.to_s)}\n```#{transcripts.to_json}```"
        ask(prompt, response_type: 'QuizSchema')
      end

      def generate_questions(count, transcripts, documents)
        prompt = "#{QUESTION_GENERATION_PROMPT.gsub('#COUNT', count.to_s)}\n```#{transcripts.to_json}```"
        ask(prompt, file_path: documents, response_type: 'QuestionSchema')
      end

      private

      def ask(prompt, file_path: nil, response_type: :text)
        service = RubyLLM.chat(model: model, provider: :gemini)
        json_schema = schema_class(response_type)
        service = service.with_schema(json_schema) if json_schema.present?

        if response_type == :json || json_schema.present?
          service = service.with_params(generationConfig: { response_mime_type: 'application/json' })
        end

        response = service.ask prompt, with: file_path

        response.content

        Result.ok(response.content)
      rescue StandardError => e
        log_error_to_sentry(e.message)

        Result.error(e.message)
      end

      def response_type_allowed?(response_type)
        RESPONSE_TYPES.include?(response_type.to_sym)
      end

      def schema_class(response_type)
        return nil if response_type_allowed?(response_type)

        str_response_type = response_type.to_s.camelize
        JsonSchema.const_get(str_response_type)
      rescue NameError
        raise StandardError, "Schema class or implementation not found for response type: #{response_type}"
      end
    end
  end
end
