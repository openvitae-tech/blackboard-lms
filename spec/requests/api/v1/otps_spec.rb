# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::OtpsController', type: :request do
  let(:phone) { '9999999999' }
  let(:name) { 'Deepak' }
  let(:auth_token) { Rails.application.credentials[:api_token] }

  before do
    Rails.cache.clear
  end

  describe 'POST /api/v1/otps/generate' do
    it 'sends unauthorized response if auth_token is missing' do
      post '/api/v1/otps/generate', params: { phone: phone, name: name }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'calls OtpService and send otp to user' do
      post '/api/v1/otps/generate', params: { phone: phone, name: name, auth_token: }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ 'success' => true })
    end

    it 'return error response if the attempts exceeds the limit' do
      2.times { post '/api/v1/otps/generate', params: { phone: phone, name: name, auth_token: } }

      post '/api/v1/otps/generate', params: { phone: phone, name: name, auth_token: }

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq({ 'success' => false })
    end
  end

  describe 'POST /api/v1/otps/verify' do
    context 'when otp is correct' do
      it 'sends unauthorized response if auth_token is missing' do
        post '/api/v1/otps/verify', params: { phone: phone, otp: '1234' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns success true with 200' do
        mobile_no = MobileNumber.new(value: '9999999999', country_code: AVAILABLE_COUNTRIES[:india][:code])
        Auth::OtpService.new(mobile_no, name:).generate_otp
        post '/api/v1/otps/verify', params: { phone: mobile_no.value, otp: '1212', auth_token: }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq({ 'success' => true })
      end
    end

    context 'when otp is incorrect' do
      it 'sends unauthorized response if auth_token is incorrect' do
        post '/api/v1/otps/verify', params: { phone: phone, otp: '1234', auth_token: 'safdasfasdfsdaf' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns success false with 400' do
        mobile_no = MobileNumber.new(value: '9999999999', country_code: AVAILABLE_COUNTRIES[:india][:code])
        Auth::OtpService.new(mobile_no, name:).generate_otp
        post '/api/v1/otps/verify', params: { phone: mobile_no.value, otp: '0000', auth_token: }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq({ 'success' => false })
      end
    end
  end

  describe 'POST /api/v1/otps/generate_or_verify' do
    it 'sends unauthorized response if auth_token is missing' do
      post '/api/v1/otps/generate_or_verify', params: { phone: phone, name: 'Deepak' }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'Generates otp when the param otp is not present' do
      post '/api/v1/otps/generate_or_verify', params: { phone: phone, name: 'Deepak', auth_token: }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ 'success' => true })
    end

    it 'Verifies if the otp is present' do
      mobile_no = MobileNumber.new(value: '9999999999', country_code: AVAILABLE_COUNTRIES[:india][:code])
      Auth::OtpService.new(mobile_no, name:).generate_otp
      post '/api/v1/otps/generate_or_verify', params: { phone: phone, otp: '1212', auth_token: }
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ 'success' => true })
    end
  end
end
