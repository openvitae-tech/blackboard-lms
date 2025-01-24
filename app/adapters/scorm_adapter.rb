# frozen_string_literal: true

class ScormAdapter
  attr_reader :course

  def initialize(course)
    @course = course
  end

  def process
    Scorm::Course.new(course)
  end
end
