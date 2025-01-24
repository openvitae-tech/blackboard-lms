module Embeds
  class VideosController < ApplicationController
    include LessonsHelper

    skip_before_action :authenticate_user!

    before_action :set_local_content
    before_action :set_scorm_token
    after_action :allow_iframe

    def show
      if @scorm_token.present?
        @video_iframe = @local_content.present? ? get_video_iframe(@local_content) : nil
        render layout: false, content_type: 'text/html'
      else
        render plain: 'Invalid token'
      end
    end

    private

    def set_local_content
      @local_content = LocalContent.find_by(id: params[:id])
    end

    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end

    def set_scorm_token
      @scorm_token = ScormToken.find_by(token: request.headers['X-Scorm-Token'])
    end
  end
end
