# frozen_string_literal: true

module Integrations
  module Llm
    class Api
      def self.supported_llms
        {
          ollama: Integrations::Llm::Ollama,
          gemini: Integrations::Llm::Gemini
        }
      end

      def self.llm_instance(provider:, model: nil)
        llm_class = supported_llms.fetch(provider) do
          raise ArgumentError, "Unsupported LLM provider: #{provider}."
        end

        if model && llm_class::SUPPORTED_MODELS.exclude?(model)
          raise ArgumentError,
                "Unsupported model '#{model}' for #{provider}. Allowed: #{llm_class::SUPPORTED_MODELS.join(', ')}"
        end

        llm_class.new(model)
      end

      def chat(prompt)
        raise NotImplementedError, "#{self.class.name} must implement #{__method__} method."
      end
    end
  end
end
