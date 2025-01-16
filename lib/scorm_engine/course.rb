# frozen_string_literal: true

module ScormEngine
  class Course < ApplicationRecord
    self.abstract_class = true

    attr_accessor :title, :description, :course_modules
  end
end
