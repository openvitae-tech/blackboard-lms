# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :request do
  describe 'GET #not_found' do
    it 'renders the 404 page' do
      get '/invalid_path'

      expect(response).to have_http_status(:not_found)
    end
  end
end
