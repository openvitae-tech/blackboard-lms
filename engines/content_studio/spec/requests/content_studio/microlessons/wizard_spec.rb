# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Microlessons::Wizard', type: :request do
  describe 'GET /content_studio/microlessons/new' do
    before { get '/content_studio/microlessons/new' }

    it 'returns HTTP 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the Prompt step label' do
      expect(response.body).to include('Prompt')
    end

    it 'renders the Microlesson title field' do
      expect(response.body).to include('Microlesson title')
    end

    it 'renders the prompt textarea' do
      expect(response.body).to include('What should this microlesson teach?')
    end

    it 'renders the character counter' do
      expect(response.body).to include('aim for 40–80 words')
    end

    it 'renders the Continue to Video style button' do
      expect(response.body).to include('Continue to Video style')
    end

    it 'renders the video-camera icon for the Configure Video step' do
      expect(response.body).to include('m15.75 10.5 4.72-4.72')
    end

    it 'renders the Cancel button' do
      expect(response.body).to include('Cancel')
    end
  end

  describe 'GET /content_studio/microlessons/:id/configure' do
    before do
      allow(ContentStudio::ApiClient).to receive(:list_templates).and_return([])
      get '/content_studio/microlessons/pending/configure'
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the Configure Video step label' do
      expect(response.body).to include('Configure Video')
    end

    it 'renders the video-camera icon for the Configure Video step' do
      expect(response.body).to include('m15.75 10.5 4.72-4.72')
    end

    it 'renders the Choose a video template section' do
      expect(response.body).to include('Choose a video template')
    end

    it 'renders the Upload your logo section' do
      expect(response.body).to include('Upload your logo')
    end

    it 'renders the Background style section with options' do
      expect(response.body).to include('Background style')
      expect(response.body).to include('Image')
      expect(response.body).to include('Video')
      expect(response.body).to include('Plain')
    end

    it 'renders the Continue to script review button' do
      expect(response.body).to include('Continue to script review')
    end

    it 'renders the Back button' do
      expect(response.body).to include('Back')
    end
  end

  describe 'POST /content_studio/microlessons' do
    before do
      post '/content_studio/microlessons',
           params: { title: 'KYC Refresher', prompt: 'Explain KYC verification steps.' }
    end

    it 'redirects to configure step' do
      expect(response).to redirect_to('/content_studio/microlessons/pending/configure')
    end
  end

  describe 'GET /content_studio/microlessons/new after submitting the Prompt step' do
    before do
      post '/content_studio/microlessons',
           params: { title: 'KYC Refresher', prompt: 'Explain KYC verification steps.' }
      get '/content_studio/microlessons/new'
    end

    it 'preserves the previously entered title' do
      expect(response.body).to include('value="KYC Refresher"')
    end

    it 'preserves the previously entered prompt' do
      expect(response.body).to include('Explain KYC verification steps.')
    end
  end

  describe 'GET /content_studio/microlessons/new?fresh=true' do
    before do
      post '/content_studio/microlessons',
           params: { title: 'KYC Refresher', prompt: 'Explain KYC verification steps.' }
      get '/content_studio/microlessons/new', params: { fresh: true }
    end

    it 'does not preserve the previously entered title' do
      expect(response.body).not_to include('value="KYC Refresher"')
    end

    it 'does not preserve the previously entered prompt' do
      expect(response.body).not_to include('Explain KYC verification steps.')
    end
  end
end
