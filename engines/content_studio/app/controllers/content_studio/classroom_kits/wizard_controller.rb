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
        @selected_components = %w[slide_deck trainer_guide learner_workbook assessment quiz]
      end

      def update_config
        session[:kit_wizard_components] = Array(params[:components])
        redirect_to generating_classroom_kit_path(id: :pending)
      end

      def generating
        @state = params[:state] || 'pending'
      end

      def start_generation
        file_urls  = session.delete(:kit_wizard_file_urls) || []
        components = session.delete(:kit_wizard_components) || []
        title      = session.delete(:kit_wizard_title)

        Rails.logger.info("[ContentStudio] kit start_generation files=#{file_urls.inspect} " \
                          "components=#{components.inspect}")

        kit_id = ApiClient.create_classroom_kit(files: file_urls, components: components)
        Rails.cache.write("kit_title_#{kit_id}", title, expires_in: 90.days) if title.present?
        render json: { redirect_url: generating_classroom_kit_url(id: kit_id, state: 'success') }
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] kit start_generation failed: #{e.message}")
        render json: { redirect_url: generating_classroom_kit_url(id: :pending, state: 'error') },
               status: :unprocessable_content
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
