# frozen_string_literal: true

class CourseRatingJob < BaseJob
  def perform
    Rails.logger.info "Starting CourseRatingJob at #{Time.current}"

    service = Courses::RatingService.new
    service.process
  end
end
