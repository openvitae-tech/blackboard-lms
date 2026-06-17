# frozen_string_literal: true

module ContentStudio
  module ClassroomKits
    class WizardController < ApplicationController
      include WizardUploadConcern

      def new
        clear_kit_wizard_session
        @existing_files = []
      end

      def create
        removed_urls = Array(params[:removed_files])
        existing_urls = (session[:kit_wizard_file_urls] || []).reject { |u| removed_urls.include?(u) }
        existing_meta = (session[:kit_wizard_file_metadata] || []).reject { |m| removed_urls.include?(m['url']) }

        new_urls, new_meta = upload_files_with_meta(params[:documents])

        session[:kit_wizard_file_urls] = existing_urls + new_urls
        session[:kit_wizard_file_metadata] = existing_meta + new_meta
        session[:kit_wizard_title] = params[:kit_title].presence

        redirect_to configure_classroom_kit_path(id: :pending)
      end

      def configure
        @kit_id = params[:id]
        @selected_components = %w[slide_deck_for_learners trainer_guide learner_handouts learning_notes quiz]
      end

      def update_config
        session[:kit_wizard_components] = Array(params[:components])
        redirect_to generating_classroom_kit_path(id: :pending)
      end

      def generating
        @kit_id = params[:id]
      end

      def start_generation
        file_urls  = session[:kit_wizard_file_urls] || []
        components = session[:kit_wizard_components] || []

        if file_urls.empty? || components.empty?
          return render json: { error: 'Missing files or components' }, status: :unprocessable_content
        end

        Rails.logger.info(
          "[ContentStudio] kit start_generation files=#{file_urls.count} components=#{components.inspect}"
        )

        kit_id = ApiClient.create_classroom_kit(files: file_urls, components: components)
        clear_kit_wizard_session
        render json: { kit_id:, status_url: kit_generation_status_url(id: kit_id) }
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] kit start_generation failed: #{e.message}")
        render json: { error: 'An error occurred while starting generation' }, status: :unprocessable_content
      end

      def generation_status
        result = ApiClient.kit_generation_status(params[:id])
        Rails.logger.info("[ContentStudio] kit generation_status id=#{params[:id]} status=#{result.status}")
        completed = result.status == 'COMPLETED'
        render json: {
          status: completed ? 'complete' : result.status,
          stage: result.stage,
          redirect_url: completed ? root_path : nil
        }
      end

      private

      def clear_kit_wizard_session
        session.delete(:kit_wizard_file_urls)
        session.delete(:kit_wizard_file_metadata)
        session.delete(:kit_wizard_components)
        session.delete(:kit_wizard_title)
      end
    end
  end
end
