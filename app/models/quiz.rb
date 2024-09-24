# frozen_string_literal: true

class Quiz < ApplicationRecord
  belongs_to :course_module, counter_cache: true
  has_many :quiz_answers, dependent: :destroy
end
