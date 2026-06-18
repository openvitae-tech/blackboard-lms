# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'ClassroomKits', type: :request do
  let(:learning_partner) { create(:learning_partner) }
  let(:team) { create(:team, learning_partner:) }
  let(:manager) { create(:user, :manager, t_team: team) }
  let(:admin) { create(:user, :admin) }
  let(:learner) { create(:user, :learner, t_team: team) }
  let!(:kit) { create(:classroom_kit, learning_partner:) }
  let!(:component) { create(:classroom_kit_component, classroom_kit: kit) }

  describe 'GET /classroom_kits' do
    context 'when signed in as a manager' do
      before { sign_in manager }

      it 'returns 200' do
        get classroom_kits_path
        expect(response).to have_http_status(:ok)
      end

      it 'only lists kits for the manager learning partner' do
        other_kit = create(:classroom_kit, title: 'Other Partner Kit')
        get classroom_kits_path
        expect(response.body).to include(kit.title)
        expect(response.body).not_to include(other_kit.title)
      end
    end

    context 'when signed in as an admin' do
      before { sign_in admin }

      it 'returns 403' do
        get classroom_kits_path
        expect(response).to redirect_to(error_401_path)
      end
    end

    context 'when signed in as a learner' do
      before { sign_in learner }

      it 'returns 403' do
        get classroom_kits_path
        expect(response).to redirect_to(error_401_path)
      end
    end

    context 'when not signed in' do
      it 'redirects to login' do
        get classroom_kits_path
        expect(response).to redirect_to(new_login_path)
      end
    end
  end

  describe 'GET /classroom_kits/:id' do
    context 'when signed in as a manager' do
      before { sign_in manager }

      it 'returns 200' do
        get classroom_kit_path(kit)
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when signed in as an admin' do
      before { sign_in admin }

      it 'returns 403' do
        get classroom_kit_path(kit)
        expect(response).to redirect_to(error_401_path)
      end
    end

    context 'when signed in as a learner' do
      before { sign_in learner }

      it 'returns 403' do
        get classroom_kit_path(kit)
        expect(response).to redirect_to(error_401_path)
      end
    end
  end

  describe 'GET /classroom_kits/:id/components/:component_id/download' do
    let(:neo_ai_client) { instance_double(NeoAi::Client) }
    let(:download_url) { 'https://s3.example.com/slide.pptx?token=xyz' }

    before do
      stub_const('NEO_AI_PARTNER_HMAC_SECRET', 'test-secret')
      allow(NeoAi::Client).to receive(:new).and_return(neo_ai_client)
      allow(neo_ai_client).to receive(:get_kit).and_return(
        'components' => [{ 'id' => component.neo_ai_component_id, 'download_url' => download_url }]
      )
    end

    context 'when signed in as a manager' do
      before { sign_in manager }

      it 'redirects to the pre-signed download URL' do
        get download_component_classroom_kit_path(kit, component_id: component.neo_ai_component_id)
        expect(response).to redirect_to(download_url)
      end
    end

    context 'when component is not found in NeoAi response' do
      before do
        sign_in manager
        allow(neo_ai_client).to receive(:get_kit).and_return({ 'components' => [] })
      end

      it 'returns 404' do
        get download_component_classroom_kit_path(kit, component_id: component.neo_ai_component_id)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when signed in as a learner' do
      before { sign_in learner }

      it 'returns 403' do
        get download_component_classroom_kit_path(kit, component_id: component.neo_ai_component_id)
        expect(response).to redirect_to(error_401_path)
      end
    end
  end
end
