# frozen_string_literal: true

class ProgramCourse < ApplicationRecord
  belongs_to :program, counter_cache: :courses_count
  belongs_to :course
end
