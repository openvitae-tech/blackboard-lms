# frozen_string_literal: true

module Integrations
  module Llm
    module JsonSchema
      class QuestionSchema < RubyLLM::Schema
        array :questions do
          object do
            string :question
            array :options, of: :string
            array :answers, of: :string
          end
        end
      end
    end
  end
end
