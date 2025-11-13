# frozen_string_literal: true

module Integrations
  module Llm
    module JsonSchema
      class QuizSchema < RubyLLM::Schema
        array :quizzes do
          object do
            string :question
            array :options do
              string :text
            end
            string :answer_text
          end
        end
      end
    end
  end
end
