# frozen_string_literal: true

module ContentStudio
  module Courses
    class LessonsController < ApplicationController
      def show
        @course_id = params[:course_id]
        @lesson = ApiClient.get_lesson(@course_id, params[:id])

        structure = ApiClient.course_structure(@course_id)
        @progress_text = structure.progress_text
        @stage = structure.stage
        @banner_url = structure.thumbnail_url

        all_lessons = structure.modules.flat_map(&:lessons)
        current_index = all_lessons.index { |l| l.id == params[:id] }

        @prev_lesson_id = current_index && current_index > 0 ? all_lessons[current_index - 1].id : nil
        @next_lesson_id = current_index && current_index < all_lessons.size - 1 ? all_lessons[current_index + 1].id : nil
      end
    end
  end
end
