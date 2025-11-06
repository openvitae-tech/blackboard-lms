# frozen_string_literal: true

module MyProfilesHelper
  def linkedin_share_url(certificate_uuid)
    app_url = Rails.application.credentials.dig(:app, :base_url)
    certificate_url = "#{app_url}/certificates/#{certificate_uuid}"

    "https://www.linkedin.com/sharing/share-offsite/?url=#{certificate_url}"
  end

  def get_certificate(user, course_id)
    user.course_certificates.find_by(course_id:)
  end
end
