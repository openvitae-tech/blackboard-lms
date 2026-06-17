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

  describe 'POST /content_studio/classroom-kits/start_generation' do
    context 'when session is missing file_urls or components' do
      it 'returns 422 with an error message' do
        post '/content_studio/classroom-kits/start_generation'
        expect(response).to have_http_status(422)
        expect(response.parsed_body['error']).to eq('Missing files or components')
      end
    end

    context 'when ApiClient raises a Faraday::Error' do
      before do
        allow_any_instance_of(ContentStudio::WizardUploadConcern)
          .to receive(:upload_files_with_meta)
          .and_return([['https://example.com/file.pdf'], [{ 'url' => 'https://example.com/file.pdf' }]])
        allow(ContentStudio::ApiClient).to receive(:create_classroom_kit).and_raise(Faraday::Error)
        post '/content_studio/classroom-kits'
        patch '/content_studio/classroom-kits/pending/configure', params: { components: %w[quiz] }
      end

      it 'returns 422 with a generic error message' do
        post '/content_studio/classroom-kits/start_generation'
        expect(response).to have_http_status(422)
        expect(response.parsed_body['error']).to eq('An error occurred while starting generation')
      end
    end
  end

  describe 'GET /content_studio/classroom-kits/:id/generation_status' do
    let(:pending_result) do
      ContentStudio::GenerationStatus.new(status: 'PENDING', stage: 'Uploading your document…', redirect_url: nil)
    end
    let(:completed_result) do
      ContentStudio::GenerationStatus.new(status: 'COMPLETED', stage: nil, redirect_url: nil)
    end

    context 'when generation is still pending' do
      before { allow(ContentStudio::ApiClient).to receive(:kit_generation_status).and_return(pending_result) }

      it 'returns status PENDING with a stage and no redirect_url' do
        get '/content_studio/classroom-kits/kit-abc/generation_status'
        expect(response).to have_http_status(:ok)
        body = response.parsed_body
        expect(body['status']).to eq('PENDING')
        expect(body['stage']).to eq('Uploading your document…')
        expect(body['redirect_url']).to be_nil
      end
    end

    context 'when generation is completed' do
      before { allow(ContentStudio::ApiClient).to receive(:kit_generation_status).and_return(completed_result) }

      it 'returns status complete' do
        get '/content_studio/classroom-kits/kit-abc/generation_status'
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['status']).to eq('complete')
      end
    end
  end
end
