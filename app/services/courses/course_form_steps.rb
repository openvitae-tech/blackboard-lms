# frozen_string_literal: true

module Courses
  class CourseFormSteps
    STEP_ONE = 1
    STEP_TWO = 2

    STEP_ONE_FIELDS = %i[title category_id level_id].freeze
    STEP_TWO_FIELDS = %i[description banner visibility].freeze

    def self.error_step_for(course)
      return STEP_ONE if step_one_error?(course)
      return STEP_TWO if step_two_error?(course)

      STEP_ONE
    end

    class << self
      private

      def step_one_error?(course)
        STEP_ONE_FIELDS.any? { |field| course.errors.key?(field) }
      end

      def step_two_error?(course)
        STEP_TWO_FIELDS.any? { |field| course.errors.key?(field) }
      end
    end
  end
end
