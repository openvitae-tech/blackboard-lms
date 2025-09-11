# frozen_string_literal: true

class MyProfilesController < ApplicationController
  before_action :set_course_certificates, only: :show

  def show
    render
  end

  private

  def set_course_certificates
    @course_certificates = current_user.course_certificates.includes([:course, :file_attachment])
  end
end
