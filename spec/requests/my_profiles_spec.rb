# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for MyProfiles', type: :request do
  let(:learning_partner) { create(:learning_partner) }

  let(:learner) { create :user, :learner, learning_partner: }
  let(:admin) { create :user, :admin }

  before do
    @certificate_template = create(:certificate_template, learning_partner:, active: true)

    @course_one = create :course
    @course_two = create :course

    @course_one.enroll!(learner)
    @course_two.enroll!(learner)

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

  describe 'GET /share_certificate' do
    it 'allow access to sharing course certificate' do
      get share_certificate_profile_path, params: { certificate_id: @course_certificate_one.id }

      expect(response.status).to be(200)
      expect(response).to render_template(:share_certificate)
    end
  end

  describe 'POST /generate_certificate' do
    it 'allow generating certificate' do
      learning_partner.reload
      learner.enrollments.first.complete_course!

      Rails.cache.clear

      Sidekiq::Testing.fake! do
        expect do
          post generate_certificate_profile_path, params: { enrollment_id: learner.enrollments.first.id },
                                                  headers: { 'ACCEPT' => 'text/vnd.turbo-stream.html' }
          expect(response.status).to be(200)

          expect(flash[:success]).to eq('Certificate will be available soon')
        end.to change(GenerateCourseCertificateJob.jobs, :size).by(1)
      end
    end
  end
end
