# frozen_string_literal: true

class ScormAdapter
  attr_reader :course, :scorm_token

  def initialize(course, scorm_token)
    @course = course
    @scorm_token = scorm_token
  end

  def process
    Scorm::Course.new(course, scorm_token)
  end
end
