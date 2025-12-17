# frozen_string_literal: true

DISCOUNTED_FACTOR = 0.8

namespace :one_timer do
  desc 'Generate course ratings based on lesson ratings'
  task generate_course_ratings: :environment do
    events_by_lesson = {}
    Event.where(name: 'lesson_rating').find_each do |event|
      lesson_id = event.data['lesson_id']
      events_by_lesson[lesson_id] ||= []
      events_by_lesson[lesson_id] << event
    end

    return if events_by_lesson.empty?

    events_by_lesson.each do |lesson_id, events|
      ratings = events.map { |e| e.data['rating'].to_f }
      average_rating = ratings.sum / ratings.size
      lesson = Lesson.find_by(id: lesson_id)

      next unless lesson

      new_rating = 0.5 * (average_rating + (DISCOUNTED_FACTOR * lesson.current_rating))
      lesson.update!(rating: new_rating.round(1), last_rated_at: events.max_by(&:created_at).created_at)
    end

    CourseRatingJob.perform_async
  end
end
