class QuizAnswer < ApplicationRecord

  STATUS_MAPPING  = {
    correct: "correct",
    incorrect: "incorrect",
    skipped: "skipped"
  }

  VALID_OPTIONS = %w[a b c d skip]

  belongs_to :quiz
  belongs_to :enrollment

  validates :status, presence: true, inclusion: { in: STATUS_MAPPING.values }
  validates :answer, presence: true, inclusion: { in: VALID_OPTIONS }
end
