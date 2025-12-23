# frozen_string_literal: true

class LessonRatingJob < BaseJob
  def perform
    Rails.logger.info "Starting LessonRatingJob at #{Time.current}"

    service = Lessons::RatingService.instance
    service.calculate_ratings(date: Date.yesterday.all_day)
  end
end
