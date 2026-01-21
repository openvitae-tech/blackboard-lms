# frozen_string_literal: true

module Assessments
  class PresenterService
    SMALL_DEVICE_NAVIGATION_COLS = 5

    STATUS = { current: :current, answered: :answered, not_answered: :not_answered, skipped: :skipped }.freeze

    attr_reader :assessment

    def initialize(assessment)
      @assessment = assessment
    end

    def current_index
      assessment.current_question_index
    end

    def current_question_data
      assessment.questions[current_index]
    end

    def question_statuses
      @question_statuses ||= assessment.questions.map.with_index do |q_data, index|
        q_id = q_data['id'].to_s
        answer = assessment.responses[q_id]

        status = if index == current_index
                   STATUS[:current]
                 elsif answer.present?
                   STATUS[:answered]
                 elsif assessment.responses.key?(q_id) && answer.blank?
                   STATUS[:skipped]
                 else
                   STATUS[:not_answered]
                 end
        { index: index, status: status }
      end
    end

    def counts
      @counts ||= {
        answered: question_statuses.count { |s| s[:status] == STATUS[:answered] },
        skipped: question_statuses.count { |s| s[:status] == STATUS[:skipped] },
        not_answered: question_statuses.count { |s| s[:status] == STATUS[:not_answered] }
      }
    end

    def time_remaining
      ((Assessment::QUESTIONS_COUNT * 60) - (assessment.time_taken * 60)) / 60
    end

    def questions_count
      @questions_count ||= assessment.questions.count
    end

    def question_selections
      return @question_selections if @question_selections

      start_idx = (current_index / SMALL_DEVICE_NAVIGATION_COLS) * SMALL_DEVICE_NAVIGATION_COLS
      end_idx = [start_idx + SMALL_DEVICE_NAVIGATION_COLS - 1, questions_count - 1].min
      @question_selections = question_statuses[start_idx..end_idx]
    end
  end
end
