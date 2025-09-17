# frozen_string_literal: true

class CertificatesController < ApplicationController
  skip_before_action :authenticate_user!

  before_action :set_certificate

  def show
    if @certificate.present?
      redirect_to rails_blob_url(@certificate.certificate_thumbnail, disposition: "inline")
    else
      render "pages/not_found", status: :not_found, layout: "public"
    end
  end

  private

  def set_certificate
    @certificate = CourseCertificate.find_by(certificate_uuid: params[:id])
  end
end
