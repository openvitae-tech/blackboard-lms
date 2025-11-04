# frozen_string_literal: true

module Integrations
  module Llm
    module JsonSchema
      class TranscriptSchema < RubyLLM::Schema
        array :segments do
          object do
            integer :start_at
            integer :end_at
            string :text
          end
        end
      end
    end
  end
end
