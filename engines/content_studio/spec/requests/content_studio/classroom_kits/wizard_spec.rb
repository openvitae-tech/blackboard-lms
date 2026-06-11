# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::ClassroomKits::Wizard', type: :request do
  describe 'GET /content_studio/classroom-kits/new' do
    it 'returns HTTP 200' do
      get '/content_studio/classroom-kits/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /content_studio/classroom-kits' do
    it 'redirects to configure step after upload' do
      post '/content_studio/classroom-kits'
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include('configure')
    end
  end

  describe 'GET /content_studio/classroom-kits/:id/configure' do
    it 'returns HTTP 200' do
      get '/content_studio/classroom-kits/pending/configure'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /content_studio/classroom-kits/:id/configure' do
    it 'redirects to the generating page' do
      patch '/content_studio/classroom-kits/pending/configure',
            params: { components: %w[slide_deck_for_learners trainer_guide learner_handouts learning_notes quiz] }
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include('generating')
    end
  end

  describe 'GET /content_studio/classroom-kits/:id/generating' do
    it 'returns HTTP 200' do
      get '/content_studio/classroom-kits/pending/generating'
      expect(response).to have_http_status(:ok)
    end
  end
end
