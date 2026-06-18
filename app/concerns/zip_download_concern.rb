# frozen_string_literal: true

module ZipDownloadConcern
  extend ActiveSupport::Concern

  EXTENSIONS = {
    'application/pdf' => 'pdf',
    'application/vnd.openxmlformats-officedocument.presentationml.presentation' => 'pptx',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document' => 'docx',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' => 'xlsx'
  }.freeze

  private

  def build_zip(components)
    conn = Faraday.new(request: { open_timeout: 5, timeout: 60 })
    Zip::OutputStream.write_buffer do |zip|
      components.each { |component| write_zip_entry(zip, conn, component) }
    end
  end

  def write_zip_entry(zip, conn, component)
    file = conn.get(component['download_url'])
    unless file.success?
      Rails.logger.warn("[ZipDownload] skipping #{component['id']} — #{file.status}")
      return
    end

    content_type = file.headers['content-type'] || 'application/octet-stream'
    ext = ext_for(content_type)
    zip.put_next_entry("#{(component['type'] || 'component').parameterize}-#{component['id']}.#{ext}")
    zip.write(file.body)
  end

  def ext_for(content_type)
    EXTENSIONS[content_type.split(';').first.strip] || 'bin'
  end
end
