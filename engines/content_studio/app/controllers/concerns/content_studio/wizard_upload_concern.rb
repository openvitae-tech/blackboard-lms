# frozen_string_literal: true

module ContentStudio
  module WizardUploadConcern
    extend ActiveSupport::Concern

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
      uri = URI.parse(ContentStudio.public_host)
      default_port = uri.scheme == 'https' ? 443 : 80
      port = uri.port == default_port ? nil : uri.port
      main_app.rails_storage_proxy_url(blob, host: uri.host, protocol: uri.scheme, port: port)
    end
  end
end
