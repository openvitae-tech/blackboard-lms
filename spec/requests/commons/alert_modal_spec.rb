# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for AlertModal', type: :request do
  let(:user) { create(:user, :admin) }

  before do
    sign_in user
  end

  describe 'GET /alert_modal' do
    it 'renders alert modal' do
      get alert_modal_path, params: alert_params
      expect(response).to have_http_status(:success)
      expect(response).to render_template(:show)
    end
  end

  private

  def alert_params
    {
      title: 'Confirm Action',
      description: "You are permanently deleting the course. This action can't be undone.",
      method: 'delete',
      action_path: '/courses/1'
    }
  end
end
