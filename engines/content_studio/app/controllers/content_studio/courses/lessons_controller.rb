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

        @prev_lesson_id = current_index&.positive? ? all_lessons[current_index - 1].id : nil
        @next_lesson_id = current_index && current_index < all_lessons.size - 1 ? all_lessons[current_index + 1].id : nil # rubocop:disable Layout/LineLength
        @lesson_number = current_index ? current_index + 1 : nil
        @total_lessons = all_lessons.size
      end

      def destroy
        ApiClient.delete_lesson(params[:id], course_id: params[:course_id])
        redirect_to course_structure_path(id: params[:course_id])
      end

      def regenerate
        ApiClient.regenerate_lesson(params[:id], course_id: params[:course_id])
        redirect_to course_lesson_path(params[:course_id], params[:id])
      end

      def verify
        ApiClient.verify_lesson(params[:id], course_id: params[:course_id])
        next_id = params[:next_lesson_id]
        if next_id.present?
          redirect_to course_lesson_path(params[:course_id], next_id)
        else
          redirect_to course_structure_path(id: params[:course_id])
        end
      end

      def scene_status
        lesson = ApiClient.get_lesson(params[:course_id], params[:id])
        scenes = lesson.scenes.map do |s|
          { id: s.id, status: s.status, video_url: s.video_url, thumbnail_url: s.thumbnail_url }
        end
        render json: { scenes:, pending: scenes.any? { |s| s[:video_url].blank? } }
      end
    end
  end
end
