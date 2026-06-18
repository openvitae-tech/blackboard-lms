# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::ClassroomKits::Wizard', type: :request do
  describe 'GET /content_studio/classroom-kits/new' do
    it 'returns HTTP 200' do
      get '/content_studio/classroom-kits/new'
      expect(response).to have_http_status(:ok)
    end

    it 'preserves wizard session when fresh param is absent' do
      post '/content_studio/classroom-kits', params: { kit_title: 'My Kit' }
      get '/content_studio/classroom-kits/new'
      expect(session[:kit_wizard_title]).to eq('My Kit')
    end

    it 'clears wizard session when fresh param is present' do
      post '/content_studio/classroom-kits', params: { kit_title: 'My Kit' }
      get '/content_studio/classroom-kits/new', params: { fresh: true }
      expect(session[:kit_wizard_title]).to be_nil
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
    it 'saves components to session and redirects to generating page' do
      patch '/content_studio/classroom-kits/pending/configure',
            params: { components: %w[slide_deck trainer_guide] }
      expect(response).to have_http_status(:redirect)
      expect(response.location).to include('generating')
    end
  end

  describe 'GET /content_studio/classroom-kits/:id/generating' do
    it 'returns HTTP 200' do
      get '/content_studio/classroom-kits/pending/generating'
      expect(response).to have_http_status(:ok)
    end

    it 'returns HTTP 200 with state=error' do
      get '/content_studio/classroom-kits/pending/generating', params: { state: 'error' }
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /content_studio/classroom-kits/start_generation' do
    context 'when ApiClient succeeds' do
      before do
        allow(ContentStudio::ApiClient).to receive(:create_classroom_kit).and_return('kit-123')
        post '/content_studio/classroom-kits', params: { kit_title: 'My Kit' }
        patch '/content_studio/classroom-kits/pending/configure', params: { components: %w[slide_deck] }
      end

      it 'returns a redirect_url to the kit structure page' do
        post '/content_studio/classroom-kits/start_generation'
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['redirect_url']).to include('structure')
        expect(response.parsed_body['redirect_url']).to include('kit-123')
      end

      it 'clears all wizard session variables after generation' do
        post '/content_studio/classroom-kits/start_generation'
        expect(session[:kit_wizard_file_urls]).to be_nil
        expect(session[:kit_wizard_file_metadata]).to be_nil
        expect(session[:kit_wizard_components]).to be_nil
        expect(session[:kit_wizard_title]).to be_nil
      end

      it 'writes kit title to cache with 90-day expiry' do
        allow(Rails.cache).to receive(:write)
        post '/content_studio/classroom-kits/start_generation'
        expect(Rails.cache).to have_received(:write).with('kit_title_kit-123', 'My Kit', expires_in: 90.days)
      end
    end

    context 'when kit title is blank' do
      before do
        allow(ContentStudio::ApiClient).to receive(:create_classroom_kit).and_return('kit-456')
        post '/content_studio/classroom-kits'
        patch '/content_studio/classroom-kits/pending/configure', params: { components: %w[slide_deck] }
      end

      it 'does not write anything to cache' do
        allow(Rails.cache).to receive(:write)
        post '/content_studio/classroom-kits/start_generation'
        expect(Rails.cache).not_to have_received(:write)
      end
    end

    context 'when ApiClient raises a Faraday::Error' do
      before do
        allow(ContentStudio::ApiClient).to receive(:create_classroom_kit).and_raise(Faraday::Error)
      end

      it 'returns 422 with a redirect_url to the error generating page' do
        post '/content_studio/classroom-kits/start_generation'
        expect(response).to have_http_status(422)
        expect(response.parsed_body['redirect_url']).to include('generating')
        expect(response.parsed_body['redirect_url']).to include('state=error')
      end
    end
  end

  describe 'GET /content_studio/classroom-kits/:id/generation_status' do
    context 'when kit is COMPLETED' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_classroom_kit)
          .and_return({ 'status' => 'COMPLETED', 'stage' => 'ready' })
      end

      it 'returns status complete with a redirect_url to the structure page' do
        get '/content_studio/classroom-kits/kit-123/generation_status'
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['status']).to eq('complete')
        expect(response.parsed_body['redirect_url']).to include('structure')
        expect(response.parsed_body['redirect_url']).to include('kit-123')
      end
    end

    context 'when kit has FAILED' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_classroom_kit)
          .and_return({ 'status' => 'FAILED', 'stage' => 'failed' })
      end

      it 'returns status error with a redirect_url to the error generating page' do
        get '/content_studio/classroom-kits/kit-123/generation_status'
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['status']).to eq('error')
        expect(response.parsed_body['redirect_url']).to include('generating')
        expect(response.parsed_body['redirect_url']).to include('state=error')
      end
    end

    context 'when kit is still pending' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_classroom_kit)
          .and_return({ 'status' => 'PENDING', 'stage' => 'crafting' })
      end

      it 'returns status pending with the current stage' do
        get '/content_studio/classroom-kits/kit-123/generation_status'
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['status']).to eq('pending')
        expect(response.parsed_body['stage']).to eq('crafting')
      end
    end

    context 'when ApiClient raises a Faraday::Error' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_classroom_kit).and_raise(Faraday::Error)
      end

      it 'returns 422 with status error' do
        get '/content_studio/classroom-kits/kit-123/generation_status'
        expect(response).to have_http_status(422)
        expect(response.parsed_body['status']).to eq('error')
      end
    end
  end
end
