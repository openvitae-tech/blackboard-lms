# frozen_string_literal: true

module Integrations
  module Llm
    class Api
      attr_accessor :model

      include Singleton

      SUPPORTED_LLMS = {
        ollama: Integrations::Llm::Ollama,
        gemini: Integrations::Llm::Gemini
      }.freeze

      def self.llm_instance(provider:, model: nil)
        llm_class = SUPPORTED_LLMS.fetch(provider) do
          raise ArgumentError, "Unsupported LLM provider: #{provider}."
        end

        model ||= llm_class::DEFAULT_MODEL

        unless llm_class::SUPPORTED_MODELS.include?(model)
          raise ArgumentError,
                "Unsupported model '#{model}' for #{provider}. Allowed: #{llm_class::SUPPORTED_MODELS.join(', ')}"
        end

        llm = llm_class.instance
        llm.model = model
        llm
      end

      def chat(prompt)
        raise NotImplementedError, "#{self.class.name} must implement #{__method__} method."
      end
    end
  end
end
