# frozen_string_literal: true

module Api
  module Internal
    class CoursesController < BaseController
      SUPPORTED_LANGUAGES = %w[English Hindi Tamil Telugu Kannada Malayalam Marathi Bengali Gujarati Punjabi].freeze

      def stats
        courses = neo_ai.list_courses
        render json: {
          created: courses.count { |c| neo_completed?(c) },
          published: 0, # TODO: requires BlackboardLMS published course count
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
          languages: SUPPORTED_LANGUAGES
        }
      end

      def avatars
        render json: []
      end

      def templates
        render json: neo_ai.list_templates
      end

      def generation_status
        data = neo_ai.find_course(params[:id])
        stage = data['stage']
        completed = (data['modules'] || []).any? || stage == 'log_course_completed'
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
        NeoAi::CourseSaveService.new(neo_ai).call(params[:id], learning_partner_id: current_user.learning_partner_id)
        render json: { status: 'ok' }
      end

      def discard
        neo_ai.delete_course(params[:id])
        head :no_content
      end

      def create
        data = neo_ai.create_course(
          files: params[:files],
          branding: params[:branding]&.to_unsafe_h || {},
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

      def reorder_lesson
        neo_ai.reorder_lesson(params[:lesson_id], course_id: params[:course_id],
                                                  new_position: params[:new_position].to_i)
        render json: { status: 'ok' }
      end

      def delete_module
        neo_ai.delete_module(params[:module_id], course_id: params[:course_id])
        head :no_content
      end

      def delete_lesson
        neo_ai.delete_lesson(params[:lesson_id], course_id: params[:course_id])
        head :no_content
      end

      def regenerate_lesson
        neo_ai.regenerate_lesson(params[:lesson_id], course_id: params[:course_id])
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
          level: data['level'],
          levels: [],
          course_modules_count: data['num_modules'].to_i,
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
        scene_duration = (data['modules'] || [])
                         .flat_map { |m| m['lessons'] || [] }
                         .flat_map { |l| l['scenes'] || [] }
                         .sum { |s| s['duration'].to_f }
                         .ceil
        {
          id: data['id'],
          title: data['title'],
          duration: scene_duration.positive? ? scene_duration : nil,
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
