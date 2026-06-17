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
        flash[:notice] = t('.success')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::ResourceNotFound
        flash[:alert] = t('.not_found')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::BadRequestError
        flash[:alert] = t('.locked')
        redirect_to course_lesson_path(params[:course_id], params[:id])
      rescue Faraday::Error
        flash[:alert] = t('.error')
        redirect_to course_lesson_path(params[:course_id], params[:id])
      end

      def download
        lesson = ApiClient.get_lesson(params[:course_id], params[:id])

        unless lesson.scenes.all? { |s| s.status == 'COMPLETED' }
          flash[:alert] = t('.not_available')
          return redirect_to(course_lesson_path(params[:course_id], params[:id]))
        end

        unless lesson.verified
          flash[:alert] = t('.not_verified')
          return redirect_to(course_lesson_path(params[:course_id], params[:id]))
        end

        if lesson.video_url.blank?
          flash[:alert] = t('.not_available')
          return redirect_to(course_lesson_path(params[:course_id], params[:id]))
        end

        conn = Faraday.new(request: { open_timeout: 5, timeout: 30 })
        video = conn.get(lesson.video_url)
        unless video.success?
          flash[:alert] = t('.expired')
          return redirect_to(course_lesson_path(params[:course_id], params[:id]))
        end

        send_data video.body,
                  filename: "#{lesson.title.parameterize}-lesson.mp4",
                  type: 'video/mp4',
                  disposition: 'attachment'
      rescue Faraday::Error
        flash[:alert] = t('.expired')
        redirect_to course_lesson_path(params[:course_id], params[:id])
      end

      def reorder
        ApiClient.reorder_lesson(params[:id], course_id: params[:course_id],
                                              new_position: params[:new_position].to_i)
        render json: { status: 'ok' }
      rescue Faraday::BadRequestError
        render json: { error: t('.locked') }, status: :bad_request
      rescue Faraday::Error
        render json: { error: t('.error') }, status: :unprocessable_entity
      end

      def regenerate
        ApiClient.regenerate_lesson(params[:id], course_id: params[:course_id])
        redirect_to course_lesson_path(params[:course_id], params[:id])
      end

      def verify
        ApiClient.verify_lesson(params[:id], course_id: params[:course_id])
        flash[:notice] = t('.success')
        next_id = params[:next_lesson_id]
        if next_id.present?
          redirect_to course_lesson_path(params[:course_id], next_id)
        else
          redirect_to course_structure_path(id: params[:course_id])
        end
      rescue Faraday::ResourceNotFound
        flash[:alert] = t('.not_found')
        redirect_to course_structure_path(id: params[:course_id])
      rescue Faraday::BadRequestError
        flash[:alert] = t('.locked')
        redirect_to course_lesson_path(params[:course_id], params[:id])
      rescue Faraday::Error
        flash[:alert] = t('.error')
        redirect_to course_lesson_path(params[:course_id], params[:id])
      end

      def scene_status
        lesson = ApiClient.get_lesson(params[:course_id], params[:id])
        scenes = lesson.scenes.map do |s|
          { id: s.id, status: s.status, video_url: s.video_url, thumbnail_url: s.thumbnail_url, duration: s.duration }
        end
        render json: { scenes:, pending: scenes.any? { |s| s[:video_url].blank? } }
      end
    end
  end
end
