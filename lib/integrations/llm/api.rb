# frozen_string_literal: true

module Integrations
  module Llm
    class Api
      SUPPORTED_LLMS = {
        ollama: Integrations::Llm::Ollama,
        gemini: Integrations::Llm::Gemini
      }.freeze

      def self.llm_instance(provider:, model: nil)
        llm_class = SUPPORTED_LLMS.fetch(provider) do
          raise ArgumentError, "Unsupported LLM provider: #{provider}."
        end

        llm_class.new(model)
      end

      def chat(prompt)
        raise NotImplementedError, "#{self.class.name} must implement #{__method__} method."
      end

      def generate_transcript
        raise NotImplementedError, "#{self.class.name} must implement #{__method__} method."
      end

      def generate_quiz
        raise NotImplementedError, "#{self.class.name} must implement #{__method__} method."
      end
    end
  end
end
