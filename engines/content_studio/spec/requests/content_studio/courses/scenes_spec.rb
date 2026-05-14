# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Courses::Scenes', type: :request do
  describe 'POST /content_studio/courses/:course_id/lessons/:lesson_id/scenes/:scene_id/regenerate' do
    let(:url) { '/content_studio/courses/1/lessons/2/scenes/s1/regenerate' }
    let(:params) { { narration: 'Updated narration text.' } }

    context 'when the narration is valid and changed' do
      before do
        allow(ContentStudio::ApiClient).to receive(:regenerate_scene).and_return(nil)
        post url, params: params
      end

      it 'returns HTTP 202' do
        expect(response).to have_http_status(:accepted)
      end

      it 'calls ApiClient.regenerate_scene with the scene_id and narration' do
        expect(ContentStudio::ApiClient).to have_received(:regenerate_scene)
          .with('s1', narration: 'Updated narration text.')
      end
    end

    context 'when the narration is unchanged' do
      before do
        allow(ContentStudio::ApiClient).to receive(:regenerate_scene)
          .and_raise(Faraday::BadRequestError.new(nil))
        post url, params: params
      end

      it 'returns HTTP 400' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns an error message' do
        expect(response.parsed_body['error']).to eq('Invalid or duplicate narration')
      end
    end
  end
end
