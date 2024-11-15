# frozen_string_literal: true

class Quiz < ApplicationRecord
  belongs_to :course_module, counter_cache: true
  has_many :quiz_answers, dependent: :destroy

  validates :question, presence: true
  validates :option_a, presence: true
  validates :option_b, presence: true
  validates :option_c, presence: true
  validates :option_d, presence: true
  validates :answer, presence: true
end
