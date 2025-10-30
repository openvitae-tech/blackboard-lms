# frozen_string_literal: true

class LessonRatingJob < BaseJob
  def perform
    service = Lessons::RatingService.instance
    service.calculate_ratings
  end
end
