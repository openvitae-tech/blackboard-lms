# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Impersonations', type: :request do
  let(:user) { create(:user, :admin) }
  let(:learning_partner) { create :learning_partner }

  before do
    REDIS_CLIENT.call('FLUSHDB')
    team = create(:team, learning_partner:)
    @learner = create(:user, :learner, team:, learning_partner:)
    sign_in user
  end

  describe 'POST /impersonations' do
    it 'able to impersonate' do
      expect do
        post impersonation_path, params: { id: learning_partner.id }
        expect(flash[:notice]).to eq(t('impersonation.logged_in_as_support_user'))
      end.to change(learning_partner.users.where(role: 'support'), :count).by(1)
      support_user = learning_partner.users.find_by!(role: 'support')
      expect(REDIS_CLIENT.call('GET', "impersonated_support_user_#{support_user.id}")).to be_present
    end

    it 'able to impersonate the learning partner if already impersonating' do
      expect do
        post impersonation_path, params: { id: learning_partner.id }
      end.to change(learning_partner.users.where(role: 'support'), :count).by(1)

      sign_in user
      post impersonation_path, params: { id: learning_partner.id }
      expect(flash[:notice]).to eq(t('impersonation.logged_in_as_support_user'))
      expect(response).to redirect_to(dashboards_path)
    end

    it 'Unauthorized when accessed by non-admin' do
      sign_in @learner

      post impersonation_path, params: { id: learning_partner.id }
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end

  describe 'DELETE /impersonations' do
    before do
      post impersonation_path, params: { id: learning_partner.id }
      @support_user = learning_partner.users.find_by!(role: 'support')
    end

    it 'able to stop impersonating' do
      sign_in @support_user
      expect(REDIS_CLIENT.call('GET', "impersonated_support_user_#{@support_user.id}")).to be_present

      delete impersonation_path
      follow_redirect!

      expect(controller.current_user).to eq(user)
      expect(flash[:notice]).to eq(t('impersonation.stop_and_login'))
    end

    it 'Unauthorized when accessed by non-support user' do
      sign_in user

      delete impersonation_path
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end
end
