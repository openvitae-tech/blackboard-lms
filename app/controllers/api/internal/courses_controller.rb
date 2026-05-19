# frozen_string_literal: true

module Api
  module Internal
    class CoursesController < BaseController
      NEO_STATUS_FOR_STUDIO = {
        'verified' => 'COMPLETED',
        'published' => 'PUBLISHED'
      }.freeze
      TERMINAL_NEO_STATUSES = %w[COMPLETED PUBLISHED].freeze

      def stats
        courses = neo_ai.list_courses
        render json: {
          created: 0,
          published: courses.count { |c| c['status']&.upcase == NEO_STATUS_FOR_STUDIO['published'] },
          in_progress: courses.reject { |c| TERMINAL_NEO_STATUSES.include?(c['status']&.upcase) }.count
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
        return courses if status.blank?

        neo_target = NEO_STATUS_FOR_STUDIO[status]
        if neo_target
          courses.select { |c| c['status']&.upcase == neo_target }
        else
          courses.reject { |c| TERMINAL_NEO_STATUSES.include?(c['status']&.upcase) }
        end
      end

      def serialize_course(data)
        {
          id: data['course_id'] || data['id'],
          title: data['title'],
          description: data['description'],
          status: map_studio_status(data['status']),
          thumbnail_url: data['thumbnail_url'],
          visibility: nil,
          is_published: data['status']&.upcase == 'PUBLISHED',
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
        case raw&.upcase
        when 'COMPLETED' then 'verified'
        when 'PUBLISHED' then 'published'
        else 'to_be_verified'
        end
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
          lessons: (data['lessons'] || []).map { |l| serialize_structure_lesson(l) }
        }
      end

      def serialize_structure_lesson(data)
        scenes = (data['scenes'] || []).map { |s| serialize_scene(s) }
        verified = data['verified'] == true
        video_url = data['video_url']
        {
          id: data['id'],
          title: data['title'],
          description: data['description'],
          summary: data['summary'],
          estimated_duration: data['estimated_duration'],
          video_url: video_url,
          verified: verified,
          status: derive_lesson_status(scenes, video_url: video_url, verified: verified),
          scenes: scenes
        }
      end

      def serialize_scene(data)
        {
          id: data['id'],
          timestamp: data['timestamp'],
          visual: data['visual'],
          narration: data['narration'],
          status: data['status'],
          video_url: data['video_url'],
          thumbnail_url: data['thumbnail_url']
        }
      end

      def derive_lesson_status(scenes, video_url:, verified:)
        return 'WAITING' if scenes.empty?
        return 'VERIFIED' if verified && video_url.present?
        return 'VIDEO_READY' if scenes.all? { |s| s[:video_url].present? }

        'PENDING'
      end
    end
  end
end
