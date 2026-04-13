# frozen_string_literal: true

module Api
  module Internal
    class CoursesController < ApplicationController
      skip_before_action :verify_authenticity_token

      FIXTURES_PATH = File.expand_path('../../../../../fixtures/api', __dir__)

      def stats
        render json: File.read(File.join(FIXTURES_PATH, 'course_stats.json'))
      end

      def index
        status = params[:studio_status]
        path = File.join(FIXTURES_PATH, 'courses', "#{status}.json")
        if File.exist?(path)
          render json: File.read(path)
        else
          render json: []
        end
      end
    end
  end
end
