# frozen_string_literal: true

module ScormEngine
  class CourseModule < ApplicationRecord
    self.abstract_class = true

    attr_accessor :title, :lessons
  end
end
