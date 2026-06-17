# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Internal::ClassroomKits', type: :request do
  let(:privileged_user) { create(:user, :owner) }
  let(:learner) { create(:user, :learner) }
  let(:neo_ai) { instance_double(NeoAi::Client) }

  before do
    stub_const('NEO_AI_PARTNER_HMAC_SECRET', 'test-secret')
    allow(NeoAi::Client).to receive(:new).and_return(neo_ai)
  end

  describe 'authentication and authorization' do
    it 'returns 401 when not signed in' do
      post '/api/internal/classroom_kits'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for non-privileged users' do
      sign_in learner
      post '/api/internal/classroom_kits'
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'POST /api/internal/classroom_kits' do
    before { sign_in privileged_user }

    context 'when neo_ai returns a kit_id' do
      before do
        allow(neo_ai).to receive(:create_kit).and_return({ 'kit_id' => 'kit-abc' })
      end

      it 'returns 200 with the kit_id' do
        post '/api/internal/classroom_kits',
             params: { files: ['https://example.com/doc.pdf'], components: %w[slide_deck] }
        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['kit_id']).to eq('kit-abc')
      end

      it 'passes files and components to neo_ai.create_kit' do
        allow(neo_ai).to receive(:create_kit).and_return({ 'kit_id' => 'kit-abc' })
        post '/api/internal/classroom_kits',
             params: { files: ['https://example.com/doc.pdf'], components: %w[slide_deck trainer_guide] }
        expect(neo_ai).to have_received(:create_kit).with(
          files: ['https://example.com/doc.pdf'],
          components: %w[slide_deck trainer_guide]
        )
      end

      it 'wraps a single component string in an array' do
        allow(neo_ai).to receive(:create_kit).and_return({ 'kit_id' => 'kit-abc' })
        post '/api/internal/classroom_kits',
             params: { files: [], components: 'slide_deck' }
        expect(neo_ai).to have_received(:create_kit).with(
          files: anything,
          components: ['slide_deck']
        )
      end

      it 'writes the title to cache with 90-day expiry when title is present' do
        allow(Rails.cache).to receive(:write)
        post '/api/internal/classroom_kits',
             params: { title: 'My Kit', files: [], components: [] }
        expect(Rails.cache).to have_received(:write).with('kit_title_kit-abc', 'My Kit', expires_in: 90.days)
      end

      it 'does not write to cache when title is blank' do
        allow(Rails.cache).to receive(:write)
        post '/api/internal/classroom_kits',
             params: { files: [], components: [] }
        expect(Rails.cache).not_to have_received(:write)
      end
    end
  end
end
