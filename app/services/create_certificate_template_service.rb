# frozen_string_literal: true

class CreateCertificateTemplateService
  include Singleton
  include Rails.application.routes.url_helpers

  def generate(learning_partner, params)
    template = learning_partner.certificate_templates.build(name: params[:name])

    return template if template.name.blank? || params[:template_zip].blank?

    begin
      html, assets_map = extract_from_zip(params[:template_zip], template)
      validate_required_variables!(html)
      modified_html = replace_asset_path(html, assets_map)
      attach_html_file(template, modified_html)
    rescue StandardError => e
      template.errors.add(:base, e.message.presence || 'Template could not be processed.')
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
      filename: File.basename(updated_file_name)
    )
  end

  def replace_asset_path(html, assets_map)
    assets_map.each do |filename, blob|
      replacement =
        "data:#{blob.content_type};base64,#{Base64.strict_encode64(blob.download)}"

      html.gsub!(%r{(\./)?#{Regexp.escape(filename)}}, replacement)
    end
    html
  end

  def attach_html_file(template, html)
    template.html_file.attach(
      io: StringIO.new(html),
      filename: 'index.html',
      content_type: 'text/html'
    )
  end

  def validate_required_variables!(html)
    found = html.to_s.scan(/%\{([^}]+)\}/).flatten.uniq
    missing = CertificateTemplate::ALLOWED_VARIABLES - found
    extra = found - CertificateTemplate::ALLOWED_VARIABLES

    if missing.any?
      raise StandardError, "HTML template is missing required variables: #{missing.join(', ')}"
    elsif extra.any?
      raise StandardError, "HTML template contains invalid variables: #{extra.join(', ')}"
    end
  end
end
