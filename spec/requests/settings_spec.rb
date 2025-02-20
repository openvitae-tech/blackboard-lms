# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Settings', type: :request do
  let(:user) { create(:user, :admin) }

  before do
    sign_in user
  end

  describe 'GET /settings' do
    it 'Allow render settings page' do
      get settings_path
      expect(response.status).to be(200)
      expect(response).to render_template(:index)
    end

    it 'Unauthorized when tags is accessed by non-admin' do
      user = create(:user, :learner)
      sign_in user
      get tags_path
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
      expect(response).to redirect_to(error_401_path)
    end
  end
end
