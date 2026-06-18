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
end
