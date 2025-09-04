# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::OtpsController', type: :request do
  let(:phone) { '9999999999' }
  let(:name) { 'Deepak' }
  let(:auth_token) { Rails.application.credentials[:api_token] }

  before do
    Rails.cache.clear
  end

  describe 'GET /api/v1/otps/generate' do
    it 'sends unauthorized response if auth_token is missing' do
      get '/api/v1/otps/generate', params: { phone: phone, name: name }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'calls OtpService and returns otp in response' do
      get '/api/v1/otps/generate', params: { phone: phone, name: name, auth_token: }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ 'success' => true })
    end
  end

  describe 'GET /api/v1/otps/verify' do
    context 'when otp is correct' do
      it 'sends unauthorized response if auth_token is missing' do
        get '/api/v1/otps/verify', params: { phone: phone, otp: '1234' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns success true with 200' do
        Auth::OtpService.new(phone, name:).generate_otp
        get '/api/v1/otps/verify', params: { phone: phone, otp: '1212', auth_token: }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq({ 'success' => true })
      end
    end

    context 'when otp is incorrect' do
      it 'sends unauthorized response if auth_token is incorrect' do
        get '/api/v1/otps/verify', params: { phone: phone, otp: '1234', auth_token: 'safdasfasdfsdaf' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns success false with 400' do
        Auth::OtpService.new(phone, name:).generate_otp
        get '/api/v1/otps/verify', params: { phone: phone, otp: '0000', auth_token: }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq({ 'success' => false })
      end
    end
  end
end
