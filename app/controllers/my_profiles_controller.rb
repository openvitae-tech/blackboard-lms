# frozen_string_literal: true

class MyProfilesController < ApplicationController
  before_action :set_course_certificates
  before_action :set_course_certificate, only: :share_certificate
  before_action :set_enrollment, only: :generate_certificate

  def show
    authorize :my_profile
    @course_certificates = @course_certificates.includes(
      [:course, :file_attachment, :certificate_thumbnail_attachment]
    )
    @completed_enrollments = current_user.enrollments.where(course_completed: true).includes(:course)
    @active_template = current_user.learning_partner.active_certificate_template
    @team = Team.includes(:banner_attachment).find(current_user.team_id)
    ongoing_courses = current_user.enrollments.where(course_completed: false).includes(course: [:banner_attachment, :tags]).map(&:course)
    completed_courses = current_user.enrollments.completed.includes(course: [:banner_attachment, :tags]).map(&:course)
    @enrolled_courses_by_status = {
      t('my_profile.my_courses.ongoing') => ongoing_courses,
      t('my_profile.my_courses.completed') => completed_courses
    }.reject { |_, courses| courses.blank? }
  end

def certificates
  authorize :my_profile
  
  course_certificates = @course_certificates.includes([:course, :file_attachment])
  completed_enrollments = current_user.enrollments
                                      .where(course_completed: true)
                                      .includes(:course)
  @active_template = current_user.learning_partner.active_certificate_template

  # Combine into a single list: [{type:, data:}, ...]
  combined = course_certificates.map { |c| { type: :certificate, data: c } }

  if @active_template.present?
    certified_course_ids = course_certificates.map(&:course_id).to_set
    completed_enrollments.each do |enrollment|
      next if certified_course_ids.include?(enrollment.course_id)
      combined << { type: :request, data: enrollment }
    end
  end

  @combined_items = Kaminari.paginate_array(combined).page(params[:page]).per(10)
end

  def share_certificate
    authorize :my_profile
  end

  def generate_certificate
    authorize :my_profile

    return unless current_user.learning_partner.active_certificate_template.present?
    return if @enrollment.course_completed == false

    key = "GenerateCertificate:#{@enrollment.course_id}:#{current_user.id}"

    Rails.cache.fetch(key, expires_in: 1.hour) do
      GenerateCourseCertificateJob.perform_async(@enrollment.course_id, current_user.id,
                                                 current_user.learning_partner.active_certificate_template.id)
    end
    flash.now[:success] = t("my_profile.my_certificates.certificate_available_soon")
  end

  private

  def set_course_certificates
    @course_certificates = current_user.course_certificates
  end

  def set_course_certificate
    @course_certificate = @course_certificates.find(params[:certificate_id])
  end

  def set_enrollment
    @enrollment = current_user.enrollments.find(params[:enrollment_id])
  end
end
