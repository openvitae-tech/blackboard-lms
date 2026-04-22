# frozen_string_literal: true

module ContentStudio
  module Courses
    class WizardController < ApplicationController
      def new
        @metadata = ApiClient.course_metadata
      end

      def create
        redirect_to configure_video_path(id: 1)
      end

      def configure_video
        @course_id = params[:id]
      end

      def update_video_config
        redirect_to generating_course_path(id: params[:id])
      end

      def generating
        @course_id = params[:id]
      end

      def generation_status
        status = ApiClient.generation_status(params[:id])
        render json: { status: status.status, redirect_url: status.redirect_url }
      end
    end
  end
end
