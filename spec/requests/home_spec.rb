# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Request spec for Home', type: :request do
  let(:user) { create(:user, :admin) }

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'when user signed in as a admin' do
      get '/'
      expect(response).to redirect_to(learning_partners_path)
    end

    it 'when user signed in as a manager' do
      user.update(role: :manager)

      get '/'
      expect(response).to redirect_to(dashboards_path)
    end

    it 'when user signed in as a learner' do
      user.update(role: :learner)

      get '/'
      expect(response).to redirect_to(courses_path)
    end
  end
end
