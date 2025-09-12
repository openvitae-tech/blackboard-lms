# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for MyProfiles', type: :request do
  let(:learner) { create :user, :learner }
  let(:admin) { create :user, :admin }

  let(:learning_partner) { create(:learning_partner) }
  let(:certificate_template) { create(:certificate_template, learning_partner:) }

  before do
    @course_one = create :course
    @course_two = create :course

    @course_certificate_one = create(:course_certificate, course: @course_one, user: learner)
    @course_certificate_two = create(:course_certificate, course: @course_two, user: learner)
    sign_in learner
  end

  describe 'GET /profile' do
    it 'allows listing learner course certificates' do
      get profile_path

      expect(response.status).to be(200)
      expect(assigns(:course_certificates).pluck(:id).sort).to eq([@course_certificate_one.id,
                                                                   @course_certificate_two.id].sort)
    end

    it 'unauthorized for non-learner user' do
      sign_in admin

      get profile_path
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end
end
