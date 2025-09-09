# frozen_string_literal: true

class GenerateCourseCertificateJob < BaseJob
  def perform(course_id, user_id, certificate_template_id)
    return if course_id.blank? || user_id.blank? || certificate_template_id.blank?

    course = Course.find(course_id)
    user = User.find(user_id)
    certificate_template = CertificateTemplate.find(certificate_template_id)

    service = Courses::GenerateCertificateService.instance
    service.generate(course, user, certificate_template)
  end
end
