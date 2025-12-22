# frozen_string_literal: true

namespace :one_timer do
  desc 'Generate course ratings based on lesson ratings'
  task generate_course_ratings: :environment do
    service = Lessons::RatingService.instance
    service.calculate_ratings

    CourseRatingJob.perform_async
  end
end
