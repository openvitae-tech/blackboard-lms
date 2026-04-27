# frozen_string_literal: true

module ContentStudio
  module Courses
    class WizardController < ApplicationController
      def new
        @metadata = ApiClient.course_metadata
        @existing_files = session[:wizard_file_metadata] || []
      end

      def create
        removed_urls = Array(params[:removed_files])
        existing_urls = (session[:wizard_file_urls] || []).reject { |u| removed_urls.include?(u) }
        existing_meta = (session[:wizard_file_metadata] || []).reject { |m| removed_urls.include?(m['url']) }

        new_urls, new_meta = upload_files_with_meta(params[:documents])

        session[:wizard_file_urls] = existing_urls + new_urls
        session[:wizard_file_metadata] = existing_meta + new_meta
        session[:wizard_languages] = params[:languages]
        redirect_to configure_video_path(id: :pending)
      end

      def configure_video
        @course_id = params[:id]
      end

      def update_video_config
        session[:wizard_branding] = {
          'background_colour' => params[:background_colour],
          'text_colour' => params[:text_colour],
          'logo_url' => upload_logo(params[:logo]),
          'languages' => session.delete(:wizard_languages)
        }.compact
        redirect_to generating_course_path(id: :pending)
      end

      def start_generation
        file_urls = session.delete(:wizard_file_urls) || []
        branding = (session.delete(:wizard_branding) || {}).transform_keys(&:to_sym)

        Rails.logger.info("[ContentStudio] start_generation files=#{file_urls.inspect}")

        course_id = ApiClient.create_course(files: file_urls, branding: branding)
        render json: { course_id:, status_url: generation_status_url(id: course_id) }
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] start_generation failed: #{e.message}")
        Rails.logger.error("[ContentStudio] response body: #{e.response&.dig(:body)}")
        render json: { error: e.message }, status: :unprocessable_content
      end

      def generating
        @course_id = params[:id]
      end

      def generation_status
        result = ApiClient.generation_status(params[:id])
        Rails.logger.info("[ContentStudio] generation_status course=#{params[:id]} status=#{result.status}")
        completed = result.status == 'COMPLETED'
        render json: {
          status: completed ? 'complete' : result.status,
          stage: result.stage,
          redirect_url: completed ? course_structure_path(id: params[:id]) : nil
        }
      end

      private

      def upload_files_with_meta(files)
        return [[], []] if files.blank?

        pairs = flatten_uploads(files).filter_map do |file|
          next unless file.respond_to?(:original_filename)

          blob = ActiveStorage::Blob.create_and_upload!(
            io: file,
            filename: file.original_filename,
            content_type: file.content_type
          )
          url = blob_url(blob)
          [url, { 'name' => file.original_filename, 'url' => url }]
        end

        [pairs.map(&:first), pairs.map(&:last)]
      end

      def flatten_uploads(files)
        case files
        when ActionController::Parameters then files.values.flatten
        when Array                        then files.flatten
        else                                   [files]
        end
      end

      def upload_logo(file)
        return nil if file.blank?

        blob = ActiveStorage::Blob.create_and_upload!(
          io: file,
          filename: file.original_filename,
          content_type: file.content_type
        )
        blob_url(blob)
      end

      def blob_url(blob)
        ActiveStorage::Current.set(url_options: { host: ContentStudio.public_host }) do
          blob.url
        end
      end
    end
  end
end
