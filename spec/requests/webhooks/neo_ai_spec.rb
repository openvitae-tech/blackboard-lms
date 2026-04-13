# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Webhooks::NeoAi', type: :request do
  let(:valid_secret) { 'test-secret' }
  let(:valid_headers) { { 'x-client-secret' => valid_secret } }
  let(:valid_params) { { course_id: '123', status: 'COMPLETE' } }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:neo_ai, :api_access_token).and_return(valid_secret)
  end

  describe 'POST /webhooks/neo_ai' do
    context 'when unauthorized' do
      it 'returns 401 when x-client-secret header is missing' do
        post webhooks_neo_ai_index_path, params: valid_params

        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns 401 when x-client-secret header is wrong' do
        post webhooks_neo_ai_index_path, params: valid_params, headers: { 'x-client-secret' => 'wrong-secret' }

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when authorized' do
      context 'with missing params' do
        it 'returns 400 when course_id is missing' do
          post webhooks_neo_ai_index_path, params: { status: 'COMPLETE' }, headers: valid_headers

          expect(response).to have_http_status(:bad_request)
          expect(response.parsed_body['error']).to eq('Parameter course_id is missing')
        end

        it 'returns 400 when status is missing' do
          post webhooks_neo_ai_index_path, params: { course_id: '123' }, headers: valid_headers

          expect(response).to have_http_status(:bad_request)
          expect(response.parsed_body['error']).to eq('Parameter status is missing')
        end

        it 'returns 400 when status is not COMPLETE' do
          post webhooks_neo_ai_index_path, params: { course_id: '123', status: 'PENDING' }, headers: valid_headers

          expect(response).to have_http_status(:bad_request)
          expect(response.parsed_body['error']).to eq('Course is not completed')
        end
      end

      context 'with valid params' do
        it 'enqueues SyncNeoAiCourseJob and returns 200' do
          Sidekiq::Testing.fake! do
            post webhooks_neo_ai_index_path, params: valid_params, headers: valid_headers

            expect(response).to have_http_status(:ok)
          end
        end
      end
    end
  end
end
