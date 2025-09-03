# frozen_string_literal: true

module CourseCertificates
  class GenerateCertificate
    include Singleton

    def generate(course, user, certificate_template)
      existing_certificate = user.course_certificates.find_by(course: course)
      return existing_certificate if existing_certificate.present?

      issued_at = Time.zone.today
      certificate_id = SecureRandom.uuid
      data_map = build_data_map(course, user, issued_at, certificate_id)

      html = render_html(certificate_template, data_map)
      pdf_file = Grover.new(html).to_pdf

      filename = "certificate-#{SecureRandom.uuid}.pdf"

      certificate = user.course_certificates.new(
        course: course,
        certificate_template: certificate_template,
        issued_at: issued_at,
        certificate_id:
      )

      attach_file(certificate, pdf_file, filename)
      certificate.file_hash = Digest::SHA256.hexdigest(pdf_file)
      certificate.save!

      certificate
    end

    private

    def render_html(certificate_template, data_map)
      certificate_template.html_content.gsub(/%\{(\w+)\}/) do
        key = Regexp.last_match(1).to_sym
        data_map[key]
      end
    end

    def build_data_map(course, user, issued_at, certificate_id)
      {
        CandidateName: user.name,
        CourseName: course.title,
        IssueDate: issued_at,
        CertificateId: certificate_id
      }
    end

    def attach_file(certificate, pdf_file, filename)
      certificate.file.attach(
        io: StringIO.new(pdf_file),
        filename: filename,
        content_type: 'application/pdf'
      )
    end
  end
end
