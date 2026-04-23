# frozen_string_literal: true

module ContentStudio
  module Courses
    class LessonsController < ApplicationController
      def show
        @lesson = ApiClient.get_lesson(params[:course_id], params[:id])
        @course_id = params[:course_id]
      end
    end
  end
end
