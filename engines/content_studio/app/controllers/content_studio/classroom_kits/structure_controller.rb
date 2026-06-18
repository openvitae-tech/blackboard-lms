# frozen_string_literal: true

module ContentStudio
  module ClassroomKits
    class StructureController < ApplicationController
      def show
        @kit = ApiClient.get_classroom_kit(params[:id])
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] kit structure#show failed: #{e.message}")
        head :service_unavailable
      end

      def save
        ApiClient.save_classroom_kit(params[:id])
        flash[:notice] = t('.saved')
        redirect_to main_app.root_path
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] kit structure#save failed: #{e.message}")
        flash[:alert] = t('.save_failed')
        redirect_to kit_structure_path(id: params[:id])
      end

      def discard
        ApiClient.discard_kit(params[:id])
        redirect_to main_app.root_path
      rescue Faraday::BadRequestError
        flash[:alert] = t('content_studio.classroom_kits.discard.locked')
        redirect_to kit_structure_path(id: params[:id])
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] kit structure#discard failed: #{e.message}")
        flash[:alert] = t('.discard_failed')
        redirect_to kit_structure_path(id: params[:id])
      end

      def download
        kit = ApiClient.get_classroom_kit(params[:id])
        component = kit.components.find { |c| c.id.to_s == params[:component_id].to_s }

        return head :not_found if component.nil?
        return head :unprocessable_entity if component.download_url.blank?

        conn = Faraday.new(request: { open_timeout: 5, timeout: 60 })
        file = conn.get(component.download_url)

        return head :bad_gateway unless file.success?

        content_type = file.headers['content-type'] || 'application/octet-stream'
        filename = "#{component.type.parameterize}-kit.#{ext_for(content_type)}"
        send_data file.body, filename: filename, type: content_type, disposition: 'attachment'
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] kit component download failed: #{e.message}")
        head :bad_gateway
      end

      def download_all
        kit = ApiClient.get_classroom_kit(params[:id])
        ready_components = (kit.components || []).select { |c| c.status == 'READY' }

        return head :not_found if ready_components.empty?

        conn = Faraday.new(request: { open_timeout: 5, timeout: 60 })
        zip_data = Zip::OutputStream.write_buffer do |zip|
          ready_components.each do |component|
            next if component.download_url.blank?

            file = conn.get(component.download_url)
            next unless file.success?

            content_type = file.headers['content-type'] || 'application/octet-stream'
            entry_name = "#{component.type.parameterize}-kit.#{ext_for(content_type)}"
            zip.put_next_entry(entry_name)
            zip.write(file.body)
          end
        end

        kit_name = kit.title.presence&.parameterize || 'classroom-kit'
        send_data zip_data.string, filename: "#{kit_name}.zip", type: 'application/zip', disposition: 'attachment'
      rescue Faraday::Error => e
        Rails.logger.error("[ContentStudio] kit download_all failed: #{e.message}")
        head :bad_gateway
      end

      EXTENSIONS = {
        'application/pdf' => 'pdf',
        'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx',
        'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx'
      }.freeze

      private

      def ext_for(content_type)
        EXTENSIONS[content_type.split(';').first.strip] || 'bin'
      end
    end
  end
end
