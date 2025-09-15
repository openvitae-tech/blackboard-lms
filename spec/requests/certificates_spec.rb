# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Certificates', type: :request do
  let(:admin) { create :user, :admin }

  let(:learning_partner) { create(:learning_partner) }
  let(:learner) { create :user, :learner, learning_partner: }

  let(:certificate_template) { create(:certificate_template, learning_partner:) }

  before do
    @course_one = create :course
    @course_two = create :course

    @course_certificate = create(:course_certificate, course: @course_one, user: learner)
  end

  describe 'GET /certificates/:id' do
    it 'get course certificate' do
      get certificate_path(@course_certificate.certificate_uuid)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(
        rails_blob_url(@course_certificate.certificate_thumbnail, disposition: 'inline')
      )
    end
  end
end
