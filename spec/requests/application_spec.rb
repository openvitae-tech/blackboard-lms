# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Application', type: :request do
  describe 'invalid paths' do
    it 'redirects to the login page for invalid paths when the user is not logged in' do
      get '/invalid_path'

      expect(response.status).to be(302)
      expect(response).to redirect_to(new_login_path)
    end

    it 'redirect to not found page when the user is logged in' do
      @user = create(:user, :admin)
      sign_in @user

      get '/invalid_path'

      expect(response).to have_http_status(:not_found)
      expect(response).to render_template('pages/not_found')
    end
  end
end
