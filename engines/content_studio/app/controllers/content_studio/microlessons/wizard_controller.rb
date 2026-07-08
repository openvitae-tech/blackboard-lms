# frozen_string_literal: true

module ContentStudio
  module Microlessons
    class WizardController < ApplicationController
      include WizardUploadConcern

      def new
        clear_ml_wizard_session if params[:fresh]
        @title  = session[:ml_wizard_title]
        @prompt = session[:ml_wizard_prompt]
      end

      def create
        session[:ml_wizard_title]  = params[:title].presence
        session[:ml_wizard_prompt] = params[:prompt].presence
        redirect_to configure_microlesson_path(id: :pending)
      end

      def configure
        @microlesson_id = params[:id]
        @templates = ApiClient.list_templates
      rescue StandardError => e
        Rails.logger.error("[ContentStudio] microlesson configure failed: #{e.message}")
        @templates = []
      end

      def update_config
        logo_url         = upload_logo(params[:logo])
        template_id      = params[:template_id].presence
        background_style = params[:background_style].presence
        prompt           = session[:ml_wizard_prompt]

        microlesson_id = ApiClient.create_microlesson(
          prompt: prompt,
          document_urls: [],
          template_id: template_id,
          logo_url: logo_url,
          bg_type: map_bg_type(background_style)
        )

        clear_ml_wizard_session
        Rails.logger.info("[ContentStudio] microlesson created id=#{microlesson_id} " \
                          "template=#{template_id} background=#{background_style}")
        redirect_to configure_microlesson_path(id: microlesson_id, state: 'planning')
      rescue StandardError => e
        Rails.logger.error("[ContentStudio] microlesson create failed: #{e.message}")
        redirect_to new_microlesson_path, alert: I18n.t('content_studio.microlesson.create_failed')
      end

      private

      # Neo AI accepts: "video", "image", "none"
      # Our form sends: "video", "image", "plain" → map "plain" to "none"
      def map_bg_type(value)
        value == 'plain' ? 'none' : (value.presence || 'video')
      end

      def clear_ml_wizard_session
        session.delete(:ml_wizard_title)
        session.delete(:ml_wizard_prompt)
      end
    end
  end
end
