# frozen_string_literal: true

module ContentStudio
  module Courses
    class ScenesController < ApplicationController
      def regenerate
        ApiClient.regenerate_scene(params[:scene_id], narration: params[:narration])
        head :accepted
      rescue Faraday::BadRequestError
        render json: { error: 'Invalid or duplicate narration' }, status: :bad_request
      end
    end
  end
end
