# frozen_string_literal: true

module Api
  module Internal
    class CoursesController < ApplicationController
      skip_before_action :verify_authenticity_token

      FIXTURES_PATH = File.expand_path('../../../../../fixtures/api', __dir__)
      ALLOWED_STATUSES = %w[to_be_verified verified published].freeze

      def stats
        render json: File.read(File.join(FIXTURES_PATH, 'course_stats.json'))
      end

      def index
        status = params[:studio_status]
        return render json: [] unless ALLOWED_STATUSES.include?(status)

        path = File.join(FIXTURES_PATH, 'courses', "#{status}.json")
        if File.exist?(path)
          render json: File.read(path)
        else
          render json: []
        end
      end

      def metadata
        render json: File.read(File.join(FIXTURES_PATH, 'course_metadata.json'))
      end

      def avatars
        render json: File.read(File.join(FIXTURES_PATH, 'avatars.json'))
      end

      def templates
        render json: File.read(File.join(FIXTURES_PATH, 'templates.json'))
      end

      def generation_status
        render json: File.read(File.join(FIXTURES_PATH, 'generation_status.json'))
      end
    end
  end
end
