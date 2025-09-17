# frozen_string_literal: true

class MyProfilesController < ApplicationController
  before_action :set_course_certificates
  before_action :set_course_certificate, only: :share_certificate

  def show
    authorize :my_profile
    @course_certificates = @course_certificates.includes([:course, :file_attachment])
  end

  def share_certificate
    authorize :my_profile
  end

  private

  def set_course_certificates
    @course_certificates = current_user.course_certificates
  end

  def set_course_certificate
    @course_certificate = @course_certificates.find(params[:certificate_id])
  end
end
