# frozen_string_literal: true

module Courses
  class GenerateCertificateService
    include Singleton
    include Rails.application.routes.url_helpers

    def generate(course, user, certificate_template)
      existing_certificate = user.course_certificates.find_by(course: course)
      return if existing_certificate.present?

      issued_at = Time.zone.today
      certificate_uuid = SecureRandom.uuid

      pdf_file = generate_pdf(course, user, issued_at, certificate_template, certificate_uuid)

      filename = "certificate_#{certificate_uuid}_#{sanitize_name(course.title)}_#{sanitize_name(user.name)}.pdf"
      thumbnail_filename = "certificate_#{certificate_uuid}_" \
                           "#{sanitize_name(course.title)}_" \
                           "#{sanitize_name(user.name)}.jpeg"

      certificate = user.course_certificates.new(
        course: course,
        issued_at: issued_at,
        certificate_uuid:
      )

      jpeg_file = build_html_file(course, user, issued_at, certificate_template).to_jpeg

      attach_file(certificate, pdf_file, filename)
      attach_thumbnail(certificate, jpeg_file, thumbnail_filename)
      certificate.file_hash = Digest::SHA256.hexdigest(pdf_file)
      certificate.save!

      notify_user(user, course)
    end

    private

    def attach_file(certificate, pdf_file, filename)
      certificate.file.attach(
        io: StringIO.new(pdf_file),
        filename: filename,
        content_type: 'application/pdf'
      )
    end

    def attach_thumbnail(certificate, jpeg_file, filename)
      certificate.certificate_thumbnail.attach(
        io: StringIO.new(jpeg_file),
        filename: filename,
        content_type: 'image/jpeg',
        service_name: upload_service,
        key: "public/#{Rails.env}/certs/#{filename}"
      )
    end

    def notify_user(user, course)
      NotificationService.notify(
        user,
        I18n.t('notifications.course.certificate.title'),
        format(I18n.t('notifications.course.certificate.message'), title: course.title),
        link: profile_path
      )
    end

    def generate_pdf(course, user, issued_at, certificate_template, certificate_uuid)
      pdf_data = build_html_file(course, user, issued_at, certificate_template).to_pdf

      pdf = CombinePDF.parse(pdf_data)
      pdf.info[:certificate_uuid] = certificate_uuid
      pdf.to_pdf
    end

    def build_html_file(course, user, issued_at, certificate_template)
      data_map = build_data_map(course, user, issued_at)
      html = render_html(certificate_template, data_map)

      Grover.new(
        html,
        emulate_media: 'screen',
        full_page: true,
        print_background: true,
        landscape: true
      )
    end

    def render_html(certificate_template, data_map)
      certificate_template.html_content.gsub(/%\{(\w+)\}/) do
        key = Regexp.last_match(1).to_sym
        data_map.fetch(key) { "%{#{key}}" }
      end
    end

    def build_data_map(course, user, issued_at)
      {
        CandidateName: user.name.titleize,
        CourseName: course.title.titleize,
        IssueDate: issued_at.strftime('%d %B %Y')
      }
    end

    def sanitize_name(name)
      name.strip.downcase.gsub(/\s+/, '_')
    end

    def upload_service
      if %w[production staging].include?(Rails.env)
        :s3_public_assets_store
      else
        :local
      end
    end
  end
end
