# frozen_string_literal: true

require 'singleton'

module Integrations
  module Llm
    class Api
      include Singleton

      attr_accessor :model

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
