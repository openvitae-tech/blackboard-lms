# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::ClassroomKits::Structure', type: :request do
  describe 'PATCH /content_studio/classroom-kits/:id/save' do
    context 'when save succeeds' do
      before do
        allow(ContentStudio::ApiClient).to receive(:save_classroom_kit)
      end

      it 'redirects to the host app root' do
        patch '/content_studio/classroom-kits/kit-abc/save'
        expect(response).to redirect_to('/')
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

      it 'redirects to the host app root' do
        delete '/content_studio/classroom-kits/kit-abc'
        expect(response).to redirect_to('/')
      end

      it 'calls ApiClient.discard_kit with the kit id' do
        delete '/content_studio/classroom-kits/kit-abc'
        expect(ContentStudio::ApiClient).to have_received(:discard_kit).with('kit-abc')
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
