# frozen_string_literal: true

class QuizAnswer < ApplicationRecord
  STATUS_MAPPING = {
    correct: 'correct',
    incorrect: 'incorrect',
    skipped: 'skipped'
  }.freeze

  VALID_OPTIONS = %w[a b c d skip].freeze

  belongs_to :quiz
  belongs_to :enrollment
  belongs_to :course_module

  validates :status, presence: true, inclusion: { in: STATUS_MAPPING.values }
  validates :answer, presence: true, inclusion: { in: VALID_OPTIONS }

  def correct?
    status == STATUS_MAPPING[:correct]
  end

  def incorrect?
    status == STATUS_MAPPING[:incorrect]
  end

  def skipped?
    status == STATUS_MAPPING[:skipped]
  end

  delegate :question, to: :quiz

  def answer_text
    case answer
    when 'a' then quiz.option_a
    when 'b' then quiz.option_b
    when 'c' then quiz.option_c
    when 'd' then quiz.option_d
    else
      'Skipped'
    end
  end

  def score
    case status
    when STATUS_MAPPING[:correct] then 2
    when STATUS_MAPPING[:incorrect] then -1
    else 0
    end
  end
end
