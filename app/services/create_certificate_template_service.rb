# frozen_string_literal: true

class CreateCertificateTemplateService
  include Singleton
  include Rails.application.routes.url_helpers

  def generate(learning_partner, params)
    template = learning_partner.certificate_templates.build(name: params[:name])

    return template if template.name.blank? || params[:template_zip].blank?

    begin
      html, assets_map = extract_from_zip(params[:template_zip], template)
      template.html_content = replace_asset_path(html, assets_map)
    rescue StandardError
      template.errors.add(:base, 'Template could not be processed.')
    end
    template
  end

  private

  def extract_from_zip(zip_file, template)
    html_content = ''
    assets_map = {}

    Zip::File.open(zip_file) do |zip|
      zip.each do |entry|
        next if skip_entry?(entry)

        file_name = normalize_path(entry.name)

        if file_name == 'index.html'
          html_content = entry.get_input_stream.read
        else
          blob = upload_blob(entry, file_name)
          template.assets.attach(blob)
          assets_map[file_name] = blob
        end
      end
    end

    [html_content, assets_map]
  end

  def normalize_path(entry_name)
    entry_name.sub(%r{^[^/]+/}, '')
  end

  def skip_entry?(entry)
    entry.directory? ||
      entry.name.start_with?('__MACOSX/') ||
      File.basename(entry.name).start_with?('._') ||
      File.basename(entry.name) == '.DS_Store'
  end

  def upload_blob(entry, file_name)
    updated_file_name = "#{SecureRandom.base36}_#{file_name}"
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new(entry.get_input_stream.read),
      filename: File.basename(updated_file_name),
      service_name: upload_service,
      key: "public/#{Rails.env}/assets/#{updated_file_name}"
    )
  end

  def replace_asset_path(html, assets_map)
    assets_map.each do |filename, blob|
      replacement =
        if Rails.env.local?
          "data:#{blob.content_type};base64,#{Base64.strict_encode64(blob.download)}"
        else
          blob.url
        end

      html.gsub!(%r{(\./)?#{Regexp.escape(filename)}}, replacement)
    end
    html
  end

  def upload_service
    if %w[production staging].include?(Rails.env)
      :s3_public_assets_store
    else
      :local
    end
  end
end
