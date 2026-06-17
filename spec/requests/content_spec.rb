# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Content', type: :request do
  let(:learning_partner) { create(:learning_partner) }
  let(:team) { create(:team, learning_partner:) }
  let(:manager) { create(:user, :manager, t_team: team, learning_partner:) }
  let(:learner) { create(:user, :learner, t_team: team) }

  describe 'GET #index' do
    context 'when signed in as a manager' do
      before { sign_in manager }

      it 'returns ok' do
        get content_path
        expect(response).to have_http_status(:ok)
      end

      it 'renders the index template' do
        get content_path
        expect(response).to render_template(:index)
      end
    end

    context 'when signed in as a learner' do
      before { sign_in learner }

      it 'redirects to 401 page' do
        get content_path
        expect(response).to redirect_to(error_401_path)
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        get content_path
        expect(response).to redirect_to(new_login_path)
      end
    end
  end
end
