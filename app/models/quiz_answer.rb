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

  validates :status, presence: true, inclusion: { in: STATUS_MAPPING.values }
  validates :answer, presence: true, inclusion: { in: VALID_OPTIONS }
end
