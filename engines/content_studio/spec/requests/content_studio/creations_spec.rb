# frozen_string_literal: true

require_relative '../../rails_helper'

RSpec.describe 'ContentStudio::Creations', type: :request do
  describe 'GET /content_studio/new' do
    before { get '/content_studio/new' }

    it 'returns HTTP 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the page heading' do
      expect(response.body).to include('What do you want to create?')
    end

    it 'renders all three content type cards' do
      expect(response.body).to include('Online Course')
      expect(response.body).to include('Classroom Kit')
      expect(response.body).to include('Microlesson')
    end

    it 'renders the Continue button' do
      expect(response.body).to include('Continue')
    end

    it 'renders the Cancel button' do
      expect(response.body).to include('Cancel')
    end
  end
end
