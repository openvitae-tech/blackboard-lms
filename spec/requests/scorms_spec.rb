# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request specs for Scorms', type: :request do
  let(:user) { create(:user, :admin) }
  let(:learner) { create(:user, :learner) }
  let(:course) { create :course }
  let(:learning_partner) { create :learning_partner }

  before do
    sign_in user
  end

  describe 'GET /scorm/new' do
    it 'Allow access new scorm by admin' do
      get new_course_scorm_path(course)

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'Unauthorized when new scorm is accessed by non-admin' do
      sign_in learner

      get new_course_scorm_path(course)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'POST /scorm/create' do
    it 'allow generating scorm package download link by admin' do
      post course_scorm_path(course), params: scorm_params

      expect(assigns(:download_link)).to eq("#{request.original_url}/download?learning_partner=#{learning_partner.id}")
    end

    it 'does not allow generating scorm package download link by non-admin' do
      sign_in learner
      post course_scorm_path(course), params: scorm_params

      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'GET /scorm/download' do
    it 'allow generating scorm package by admin' do
      get download_course_scorm_path(course, learning_partner: learning_partner.id)

      expect(response.header['Content-Type']).to eq('application/zip')
      expect(response.header['Content-Disposition']).to include("#{course.title}_scorm.zip")
      expect(response).to have_http_status(:ok)
    end

    it 'does not allow generating scorm package by non-admin' do
      sign_in learner
      get download_course_scorm_path(course, learning_partner: learning_partner.id)

      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  private

  def scorm_params
    { scorm: { learning_partner_id: learning_partner.id } }
  end
end
