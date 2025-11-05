# frozen_string_literal: true

class CourseRatingJob < BaseJob
  def perform
    service = Courses::RatingService.new
    service.process
  end
end
