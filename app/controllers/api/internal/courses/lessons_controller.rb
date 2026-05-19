# frozen_string_literal: true

module Api
  module Internal
    module Courses
      class LessonsController < BaseController
        def show
          course_data = neo_ai.find_course(params[:course_id])
          lesson_data = course_data.fetch('modules', [])
                                   .flat_map { |m| m.fetch('lessons', []) }
                                   .find { |l| l['id'] == params[:id] }
          return head :not_found if lesson_data.nil?

          render json: serialize_lesson(lesson_data)
        end
      end
    end
  end
end
