module Embeds
  class VideosController < ApplicationController
    include LessonsHelper

    skip_before_action :authenticate_user!
    before_action :set_local_content
    before_action :set_learning_partner
    after_action :allow_iframe

    def show
      @is_token_valid = valid_token?
      @video_iframe = @local_content.present? ? get_video_iframe(@local_content) : nil
      render layout: false, content_type: 'text/html'
    end

    private

    def set_local_content
      @local_content = LocalContent.find_by(id: params[:id])
    end

    def set_learning_partner
      @learning_partner = LearningPartner.find(params[:learning_partner_id])
    end

    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end

    def valid_token?
       @learning_partner.scorm_token.token == request.headers['X-Scorm-Token']
    end
  end
end
