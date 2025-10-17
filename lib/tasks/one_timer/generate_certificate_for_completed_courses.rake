# frozen_string_literal: true

namespace :one_timer do
  desc 'Generate certificate for completed courses for sayaji learners'
  task generate_certificate_for_completed_courses: :environment do
    sayaji = LearningPartner.find(13)
    certificate_template = sayaji.certificate_templates.find_by(active: true)

    return if certificate_template.blank?

    enrollments = Enrollment.joins(:user).where(course_completed: true,
                                                users: { learning_partner_id: sayaji.id, role: 'learner' })
    enrollments.find_each do |enrollment|
      GenerateCourseCertificateJob.perform_async(enrollment.course_id, enrollment.user_id, certificate_template.id)
    end
  end
end
