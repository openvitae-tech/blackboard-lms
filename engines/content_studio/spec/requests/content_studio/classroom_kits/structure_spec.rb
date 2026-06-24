# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::ClassroomKits::Structure', type: :request do
  let(:ready_component) do
    ContentStudio::KitComponent.new(
      id: 'comp-1', type: 'slide_deck', title: nil,
      status: 'READY', download_url: 'https://s3.example.com/slide_deck.pptx'
    )
  end

  let(:kit) do
    ContentStudio::Kit.new(
      id: 'kit-123', title: 'Banking Basics', status: 'COMPLETED',
      stage: 'ready', thumbnail_url: nil, doc_count: 0,
      components: [ready_component]
    )
  end

  describe 'GET /content_studio/classroom-kits/:id/download_all' do
    context 'when all components are READY and files are available' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_classroom_kit).and_return(kit)
        stub_request(:get, 'https://s3.example.com/slide_deck.pptx')
          .to_return(
            status: 200,
            body: 'pptx-binary-content',
            headers: { 'Content-Type' => 'application/vnd.openxmlformats-officedocument.presentationml.presentation' }
          )
      end

      it 'returns HTTP 200' do
        get '/content_studio/classroom-kits/kit-123/download_all'
        expect(response).to have_http_status(:ok)
      end

      it 'responds with a zip content type' do
        get '/content_studio/classroom-kits/kit-123/download_all'
        expect(response.content_type).to eq('application/zip')
      end

      it 'sets a zip filename based on the kit title' do
        get '/content_studio/classroom-kits/kit-123/download_all'
        expect(response.headers['Content-Disposition']).to include('banking-basics.zip')
      end
    end

    context 'when there are no READY components' do
      before do
        pending_kit = ContentStudio::Kit.new(**kit.to_h,
          components: [ContentStudio::KitComponent.new(
            id: 'comp-1', type: 'slide_deck', title: nil, status: 'PENDING', download_url: nil
          )])
        allow(ContentStudio::ApiClient).to receive(:get_classroom_kit).and_return(pending_kit)
      end

      it 'returns HTTP 404' do
        get '/content_studio/classroom-kits/kit-123/download_all'
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the API call fails' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_classroom_kit)
          .and_raise(Faraday::Error.new('timeout'))
      end

      it 'returns HTTP 502' do
        get '/content_studio/classroom-kits/kit-123/download_all'
        expect(response).to have_http_status(:bad_gateway)
      end
    end
  end

  describe 'PATCH /content_studio/classroom-kits/:id/save' do
    context 'when save succeeds' do
      before do
        allow(ContentStudio::ApiClient).to receive(:save_classroom_kit)
      end

      it 'redirects back to the kit structure page' do
        patch '/content_studio/classroom-kits/kit-abc/save'
        expect(response).to redirect_to('/content_studio/classroom-kits/kit-abc/structure')
      end

      it 'calls ApiClient.save_classroom_kit with the kit id' do
        patch '/content_studio/classroom-kits/kit-abc/save'
        expect(ContentStudio::ApiClient).to have_received(:save_classroom_kit).with('kit-abc')
      end
    end

    context 'when save raises a Faraday error' do
      before do
        allow(ContentStudio::ApiClient).to receive(:save_classroom_kit).and_raise(Faraday::Error)
      end

      it 'redirects back to the structure page' do
        patch '/content_studio/classroom-kits/kit-abc/save'
        expect(response).to redirect_to('/content_studio/classroom-kits/kit-abc/structure')
      end
    end
  end

  describe 'DELETE /content_studio/classroom-kits/:id' do
    context 'when discard succeeds' do
      before do
        allow(ContentStudio::ApiClient).to receive(:discard_kit)
      end

      it 'redirects to the Content Studio landing page' do
        delete '/content_studio/classroom-kits/kit-abc'
        expect(response).to redirect_to(root_path)
      end

      it 'calls ApiClient.discard_kit with the kit id' do
        delete '/content_studio/classroom-kits/kit-abc'
        expect(ContentStudio::ApiClient).to have_received(:discard_kit).with('kit-abc')
      end
    end

    context 'when kit is already deleted (404)' do
      before do
        allow(ContentStudio::ApiClient).to receive(:discard_kit).and_raise(Faraday::ResourceNotFound)
      end

      it 'redirects to the Content Studio landing page' do
        delete '/content_studio/classroom-kits/kit-abc'
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when NeoAI returns 400 (kit locked)' do
      before do
        allow(ContentStudio::ApiClient).to receive(:discard_kit).and_raise(Faraday::BadRequestError)
      end

      it 'redirects back to the structure page' do
        delete '/content_studio/classroom-kits/kit-abc'
        expect(response).to redirect_to('/content_studio/classroom-kits/kit-abc/structure')
      end
    end

    context 'when discard raises a generic Faraday error' do
      before do
        allow(ContentStudio::ApiClient).to receive(:discard_kit).and_raise(Faraday::Error)
      end

      it 'redirects back to the structure page' do
        delete '/content_studio/classroom-kits/kit-abc'
        expect(response).to redirect_to('/content_studio/classroom-kits/kit-abc/structure')
      end
    end
  end
end
