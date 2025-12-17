# frozen_string_literal: true

module Courses
  class RatingService
    def process
      Course.includes(course_modules: :lessons).find_each do |course|
        lessons = course.course_modules.flat_map do |mod|
          mod.lessons.select { |lesson| lesson.last_rated_at.present? }
        end

        next if lessons.empty?

        total_rating = lessons.sum(&:current_rating)
        average_rating = total_rating / lessons.size.to_f

        course.update!(rating: average_rating.round(1))
        EVENT_LOGGER.publish_last_rated_at
      end
    end
  end
end
