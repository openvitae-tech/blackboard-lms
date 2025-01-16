# frozen_string_literal: true

module ScormEngine
  class Lesson < ApplicationRecord
    self.abstract_class = true

    attr_accessor :title, :videos
  end
end
