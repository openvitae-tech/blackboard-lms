# frozen_string_literal: true

module Integrations
  module Llm
    module JsonSchema
      class QuizSchema < RubyLLM::Schema
        array :quizzes do
          object do
            string :question
            array :options do
              object do
                string :option_label_letter
                string :option_text
              end
            end
            string :answer_letter
          end
        end
      end
    end
  end
end
