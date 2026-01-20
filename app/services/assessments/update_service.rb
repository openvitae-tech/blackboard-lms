# frozen_string_literal: true

module Assessments
  class UpdateService
    NEXT = 'Next'
    PREVIOUS = 'Previous'
    SAVE = 'Save'
    SAVE_AND_NEXT = 'Save and Next'
    SKIP_AND_NEXT = 'Skip and Next'
    SAVE_AND_SUBMIT = 'Save and Submit'
    ACTIONS = { next: NEXT,
                previous: PREVIOUS,
                save: SAVE,
                save_and_next: SAVE_AND_NEXT,
                skip_and_next: SKIP_AND_NEXT,
                save_and_submit: SAVE_AND_SUBMIT }.freeze

    attr_reader :assessment, :params, :action

    def initialize(assessment, params)
      @assessment = assessment
      @params = params
      @action = params[:commit] || ''
    end

    def call
      handle_responses
      handle_navigation
      assessment.save(validate: false)
      self
    end

    def submit?
      action == ACTIONS[:save_and_submit]
    end

    private

    def handle_responses
      q_id = params.dig(:assessment, :question_id).to_s

      if action.include?(SAVE)
        answers = params.dig(:assessment, :answer) || []
        assessment.responses[q_id] = Array.wrap(answers)
      elsif action == ACTIONS[:skip_and_next]
        assessment.responses[q_id] = [] unless assessment.responses.key?(q_id)
      end
    end

    def handle_navigation
      new_index = assessment.current_question_index

      if action.include?(NEXT)
        new_index += 1 if new_index < assessment.questions.count - 1
      elsif action == ACTIONS[:previous]
        new_index -= 1 if new_index.positive?
      elsif params[:jump_to_index].present?
        new_index = params[:jump_to_index].to_i
      end

      assessment.current_question_index = new_index
    end
  end
end
