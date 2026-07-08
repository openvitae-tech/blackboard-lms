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
      end

      def update_config
        session[:ml_wizard_logo_url]    = upload_logo(params[:logo])
        session[:ml_wizard_template_id] = params[:template_id].presence
        session[:ml_wizard_bg_type]     = map_bg_type(params[:background_style])
        redirect_to generating_microlesson_path(id: :pending)
      end

      def start_generation
        title       = session[:ml_wizard_title]
        description = session[:ml_wizard_prompt]
        template_id = session[:ml_wizard_template_id]
        logo_url    = session[:ml_wizard_logo_url]
        bg_type     = session[:ml_wizard_bg_type] || 'video'

        Rails.logger.info('[ContentStudio] microlesson start_generation')

        microlesson_id = ApiClient.create_microlesson(
          title: title,
          description: description,
          template_id: template_id,
          logo_url: logo_url,
          bg_type: bg_type
        )
        clear_ml_wizard_session
        Rails.cache.write("ml_title_#{microlesson_id}", title, expires_in: 90.days) if title.present?
        render json: { redirect_url: generating_microlesson_url(id: microlesson_id, state: 'success') }
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] microlesson start_generation failed: #{e.message}")
        render json: { redirect_url: generating_microlesson_url(id: :pending, state: 'error') },
               status: :unprocessable_content
      end

      def generating
        @state = params[:state] || 'pending'
      end

      def status
        data      = ApiClient.get_microlesson(params[:id])
        ml_status = data['status']&.upcase

        case ml_status
        when 'COMPLETED'
          render json: { status: 'complete',
                         redirect_url: generating_microlesson_url(id: params[:id], state: 'success') }
        when 'FAILED'
          render json: { status: 'error',
                         redirect_url: generating_microlesson_url(id: params[:id], state: 'error') }
        else
          stage = stage_label(data['stage'])
          render json: { status: 'pending', stage: stage }
        end
      rescue StandardError => e
        Rails.logger.error("[ContentStudio] microlesson status failed: #{e.message}")
        render json: { status: 'error',
                       redirect_url: generating_microlesson_url(id: params[:id], state: 'error') },
               status: :unprocessable_content
      end

      private

      # Maps Neo AI stage to a label that keeps the Stimulus controller
      # in the correct phase. Stages containing 'craft' stay in uploadPhase;
      # stages containing 'generat' switch to craftingPhase.
      def stage_label(stage)
        case stage
        when 'accepted', 'writing_scenes', 'planned'
          'Crafting your script…'
        when 'generating_background_media', 'generating_videos', 'workflow_done'
          'Generating your video…'
        else
          'Crafting your microlesson…'
        end
      end

      # Neo AI accepts: "video", "image", "none"
      # Our form sends: "video", "image", "plain" → map "plain" to "none"
      def map_bg_type(value)
        value == 'plain' ? 'none' : (value.presence || 'video')
      end

      def clear_ml_wizard_session
        session.delete(:ml_wizard_title)
        session.delete(:ml_wizard_prompt)
        session.delete(:ml_wizard_template_id)
        session.delete(:ml_wizard_logo_url)
        session.delete(:ml_wizard_bg_type)
      end
    end
  end
end
