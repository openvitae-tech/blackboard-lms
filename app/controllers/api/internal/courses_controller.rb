# frozen_string_literal: true

module Api
  module Internal
    class CoursesController < BaseController
      def stats
        courses = neo_ai.list_courses
        render json: {
          created: 0,
          published: 0,
          in_progress: courses.reject { |c| neo_completed?(c) }.count
        }
      end

      def index
        courses = neo_ai.list_courses
        filtered = filter_by_studio_status(courses, params[:studio_status])
        limit = params[:limit]&.to_i
        filtered = filtered.first(limit) if limit&.positive?
        render json: filtered.map { |c| serialize_course(c) }
      end

      def metadata
        render json: {
          categories: [],
          languages: %w[English Hindi Tamil Telugu Kannada Malayalam Marathi Bengali Gujarati Punjabi]
        }
      end

      def avatars
        render json: []
      end

      def templates
        render json: []
      end

      def generation_status
        data = neo_ai.find_course(params[:id])
        stage = data['stage']
        completed = data.fetch('modules', []).any? || stage == 'log_course_completed'
        render json: {
          status: completed ? 'COMPLETED' : 'PENDING',
          stage: data['progress_text'].presence || neo_ai.stage_label(stage),
          redirect_url: nil
        }
      end

      def structure
        data = neo_ai.find_course(params[:id])
        render json: serialize_structure(data)
      end

      def save
        render json: { status: 'ok' }
      end

      def discard
        neo_ai.delete_course(params[:id])
        head :no_content
      end

      def create
        data = neo_ai.create_course(
          files: params[:files],
          branding: params[:branding],
          no_video: params[:no_video].to_s == 'true'
        )
        render json: { course_id: data['course_id'] || data['id'] }
      end

      def regenerate_scene
        neo_ai.regenerate_scene(
          params[:scene_id],
          course_id: params[:course_id],
          lesson_id: params[:lesson_id],
          narration: params[:narration]
        )
        render json: { status: 'ok' }
      end

      def verify_lesson
        neo_ai.verify_lesson(params[:lesson_id], course_id: params[:course_id])
        render json: { status: 'ok' }
      end

      private

      def filter_by_studio_status(courses, status)
        case status.presence
        when nil             then courses
        when 'completed'     then courses.select { |c| neo_completed?(c) }
        when 'in_progress'   then courses.reject { |c| neo_completed?(c) }
        else []
        end
      end

      def neo_completed?(course)
        course['status']&.upcase == 'COMPLETED'
      end

      def serialize_course(data)
        {
          id: data['course_id'] || data['id'],
          title: data['title'],
          description: data['description'],
          status: map_studio_status(data['status']),
          thumbnail_url: data['thumbnail_url'],
          visibility: nil,
          duration: nil,
          rating: nil,
          banner: nil,
          categories: [],
          levels: [],
          course_modules_count: 0,
          enrollments_count: 0,
          team_enrollments_count: 0,
          modules: [],
          progress: nil
        }
      end

      def map_studio_status(raw)
        raw&.upcase == 'COMPLETED' ? 'completed' : 'in_progress'
      end

      def serialize_structure(data)
        modules = (data['modules'] || []).map { |m| serialize_structure_module(m) }
        {
          id: data['id'],
          title: data['title'],
          duration: nil,
          thumbnail_url: data['thumbnail_url'],
          progress_text: data['progress_text'],
          stage: data['stage'],
          verified_modules_count: modules.sum { |m| m[:lessons].count { |l| l[:verified] } },
          modules: modules
        }
      end

      def serialize_structure_module(data)
        {
          id: data['id'],
          title: data['title'],
          lessons: (data['lessons'] || []).map { |l| serialize_lesson(l) }
        }
      end
    end
  end
end
