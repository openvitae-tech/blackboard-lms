# frozen_string_literal: true

module Lessons
  class RatingService
    include Singleton

    DISCOUNTED_FACTOR = 0.8
    DIMINISHING_WINDOW = 30
    EPSILON = 0.5

    def rate_lesson!(user, lesson, rating)
      return if rating.nil? || rating <= 0

      EVENT_LOGGER.publish_lesson_rating(user, lesson, rating)
    end

    def calculate_ratings
      events_by_lesson = Event.where(
        name: 'lesson_rating',
        created_at: Date.yesterday.all_day
      ).group_by { |e| e.data['lesson_id'] }

      return if events_by_lesson.empty?

      events_by_lesson.each do |lesson_id, events|
        ratings = events.map { |e| e.data['rating'].to_f }
        average_rating = ratings.sum / ratings.size
        lesson = Lesson.find(lesson_id)

        # finding avg
        new_rating = 0.5 * (average_rating + (DISCOUNTED_FACTOR * lesson.current_rating))
        lesson.update!(rating: new_rating.round(1), last_rated_at: events.last.created_at)
      end
    end

    def diminished_rating(rating, last_rated_at)
      return 0 if rating.nil?

      no_days_since_last_rating = ((Time.current - last_rated_at) / 1.day).to_i

      diminishing_rate = DIMINISHING_WINDOW / [DIMINISHING_WINDOW, no_days_since_last_rating].max
      [5, (rating * diminishing_rate) + EPSILON].min
    end
  end
end
