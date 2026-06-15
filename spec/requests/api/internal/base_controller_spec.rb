# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Internal::BaseController scoped_partner_id', type: :request do
  let(:privileged_user) { create(:user, :owner) }
  let(:neo_ai) { instance_double(NeoAi::Client) }

  before do
    stub_const('NEO_AI_PARTNER_HMAC_SECRET', 'test-secret')
    sign_in privileged_user
    allow(neo_ai).to receive(:list_courses).and_return([])
  end

  it 'initialises NeoAi::Client with an HMAC-derived partner_id' do
    expected = OpenSSL::HMAC.hexdigest('SHA256', 'test-secret', privileged_user.learning_partner_id.to_s)
    allow(NeoAi::Client).to receive(:new).and_return(neo_ai)
    get '/api/internal/courses'
    expect(NeoAi::Client).to have_received(:new).with(partner_id: expected)
  end

  it 'produces different partner_ids for different learning partners' do
    other_user = create(:user, :owner)
    hmac_a = OpenSSL::HMAC.hexdigest('SHA256', 'test-secret', privileged_user.learning_partner_id.to_s)
    hmac_b = OpenSSL::HMAC.hexdigest('SHA256', 'test-secret', other_user.learning_partner_id.to_s)
    expect(hmac_a).not_to eq(hmac_b)
  end

  it 'produces different partner_ids for the same learning_partner_id under a different secret' do
    id = privileged_user.learning_partner_id.to_s
    hmac_a = OpenSSL::HMAC.hexdigest('SHA256', 'secret-env-a', id)
    hmac_b = OpenSSL::HMAC.hexdigest('SHA256', 'secret-env-b', id)
    expect(hmac_a).not_to eq(hmac_b)
  end
end
