# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Certificate templates', type: :request do
  let(:admin) { create(:user, :admin) }
  let(:learner) { create :user, :learner, learning_partner: }

  let(:learning_partner) { create(:learning_partner) }
  let!(:certificate_template) { create(:certificate_template, learning_partner:) }
  let!(:certificate_template_two) { create(:certificate_template, learning_partner:) }

  before do
    sign_in admin
  end

  describe 'GET /certificate_templates/new' do
    it 'renders new template for admin' do
      get new_learning_partner_certificate_template_path(learning_partner)

      expect(response.status).to be(200)
      expect(response).to render_template(:new)
    end

    it 'unauthorized for non-admin user' do
      sign_in learner

      get new_learning_partner_certificate_template_path(learning_partner)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'GET /certificate_templates' do
    it 'allows listing programs for admin' do
      get learning_partner_certificate_templates_path(learning_partner)

      expect(response.status).to be(200)
      expect(assigns(:certificate_templates).pluck(:id).sort).to eq([certificate_template.id,
                                                                     certificate_template_two.id].sort)
    end

    it 'unauthorized for non-admin user' do
      sign_in learner

      get learning_partner_certificate_templates_path(learning_partner)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'POST /certificate_templates' do
    it 'creates a new certificate template' do
      expect do
        post learning_partner_certificate_templates_path(learning_partner), params: certificate_template_params
      end.to change(learning_partner.certificate_templates, :count).by(1)
      expect(response).to redirect_to(learning_partner_certificate_templates_path(learning_partner))
      expect(flash[:notice]).to eq(I18n.t('resource.created', resource_name: 'Certificate Template'))
    end

    it 'unauthorized for non-admin user' do
      sign_in learner

      post learning_partner_certificate_templates_path(learning_partner), params: certificate_template_params
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end

    it 'renders new template when validation fails' do
      post learning_partner_certificate_templates_path(learning_partner), params: { certificate_template: { name: '' } }

      expect(response.status).to eq(422)
      expect(response).to render_template(:new)
    end
  end

  describe 'PATCH /certificate_templates/:id' do
    it 'updates an existing certificate template' do
      patch learning_partner_certificate_template_path(learning_partner, certificate_template),
            params: { certificate_template: { active: true } }

      expect(response).to redirect_to(learning_partner_certificate_templates_path(learning_partner))
      expect(flash[:notice]).to eq(I18n.t('resource.updated', resource_name: 'Certificate Template'))
      expect(certificate_template.reload.active).to be(true)
    end

    it 'unauthorized for non-admin user' do
      sign_in learner

      patch learning_partner_certificate_template_path(learning_partner, certificate_template),
            params: { certificate_template: { active: true } }
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'GET /certificate_templates/:id/confirm_destroy' do
    it 'renders confirm destroy template for admin' do
      get confirm_destroy_learning_partner_certificate_template_path(learning_partner, certificate_template)

      expect(response.status).to be(200)
      expect(response).to render_template(:confirm_destroy)
    end

    it 'unauthorized for non-admin user' do
      sign_in learner

      get confirm_destroy_learning_partner_certificate_template_path(learning_partner, certificate_template)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'DELETE /certificate_templates/:id' do
    it 'deletes an existing certificate template' do
      expect do
        delete learning_partner_certificate_template_path(learning_partner, certificate_template)
      end.to change(learning_partner.certificate_templates, :count).by(-1)
      expect(flash[:success]).to eq(I18n.t('resource.deleted', resource_name: 'Certificate template'))
    end

    it 'unauthorized for non-admin user' do
      sign_in learner

      delete learning_partner_certificate_template_path(learning_partner, certificate_template)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  private

  def certificate_template_params
    {
      certificate_template: {
        name: 'New Template',
        html_content: '<div>Certificate for %{CandidateName} completing %{CourseName} on %{IssueDate}.</div>' # rubocop:disable Style/FormatStringToken
      }
    }
  end
end
