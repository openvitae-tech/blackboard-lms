# frozen_string_literal: true

module Integrations
  module Llm
    module JsonSchema
      class QuestionSchema < RubyLLM::Schema
        array :questions do
          object do
            string :question
            array :options do
              string :option_text
            end
            array :answers do
              string :answer_text
            end
          end
        end
      end
    end
  end
end
