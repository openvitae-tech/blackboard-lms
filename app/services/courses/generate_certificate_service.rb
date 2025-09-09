# frozen_string_literal: true

module Courses
  class GenerateCertificateService
    include Singleton

    def generate(course, user, certificate_template)
      existing_certificate = user.course_certificates.find_by(course: course)
      return if existing_certificate.present?

      issued_at = Time.zone.today
      certificate_id = SecureRandom.uuid

      pdf_file = generate_pdf(course, user, issued_at, certificate_template, certificate_id)
      filename = "certificate-#{course.title}-#{user.name}.pdf"

      certificate = user.course_certificates.new(
        course: course,
        certificate_template: certificate_template,
        issued_at: issued_at,
        certificate_id:
      )

      attach_file(certificate, pdf_file, filename)
      certificate.file_hash = Digest::SHA256.hexdigest(pdf_file)
      certificate.save!

      notify_user(user, course)
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

    def notify_user(user, course)
      NotificationService.notify(
        user,
        I18n.t('notifications.course.certificate.title'),
        format(I18n.t('notifications.course.certificate.message'), title: course.title),
        link: ''
      )
    end

    def generate_pdf(course, user, issued_at, certificate_template, certificate_id)
      data_map = build_data_map(course, user, issued_at, certificate_id)
      html = render_html(certificate_template, data_map)

      Grover.new(
        html,
        emulate_media: 'screen',
        full_page: true,
        print_background: true
      ).to_pdf
    end
  end
end
