# frozen_string_literal: true

module Api
  module V1
    class CoursesController < ApiController
      def show
        course = Course.includes(:tags).find(params[:id])
        render json: course.to_json_data, status: :ok
      rescue ActiveRecord::RecordNotFound
        render json: { error: 'Course not found' }, status: :not_found
      end
    end
  end
end
