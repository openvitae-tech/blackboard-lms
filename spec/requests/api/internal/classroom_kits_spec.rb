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

  describe 'PATCH /api/internal/classroom_kits/:id/save' do
    let(:creator) { create(:user, :owner, content_studio_creator: true) }
    let(:save_service) { instance_double(NeoAi::ClassroomKitSaveService) }

    before do
      sign_in creator
      allow(NeoAi::ClassroomKitSaveService).to receive(:new).and_return(save_service)
      allow(save_service).to receive(:call)
    end

    it 'returns 200 and delegates to ClassroomKitSaveService' do
      patch '/api/internal/classroom_kits/kit-abc/save'
      expect(response).to have_http_status(:ok)
      expect(save_service).to have_received(:call).with('kit-abc', learning_partner_id: creator.learning_partner_id)
    end

    it 'returns 403 for a user without content_studio_creator flag' do
      sign_in privileged_user
      patch '/api/internal/classroom_kits/kit-abc/save'
      expect(response).to have_http_status(:forbidden)
    end

    it 'returns 403 for a learner' do
      sign_in learner
      patch '/api/internal/classroom_kits/kit-abc/save'
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

      it 'passes files, components and title to neo_ai.create_kit' do
        allow(neo_ai).to receive(:create_kit).and_return({ 'kit_id' => 'kit-abc' })
        post '/api/internal/classroom_kits',
             params: { title: 'Banking Basics', files: ['https://example.com/doc.pdf'],
                       components: %w[slide_deck trainer_guide] }
        expect(neo_ai).to have_received(:create_kit).with(
          files: ['https://example.com/doc.pdf'],
          components: %w[slide_deck trainer_guide],
          title: 'Banking Basics'
        )
      end

      it 'wraps a single component string in an array' do
        allow(neo_ai).to receive(:create_kit).and_return({ 'kit_id' => 'kit-abc' })
        post '/api/internal/classroom_kits',
             params: { title: 'Banking Basics', files: [], components: 'slide_deck' }
        expect(neo_ai).to have_received(:create_kit).with(
          files: anything,
          components: ['slide_deck'],
          title: 'Banking Basics'
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
