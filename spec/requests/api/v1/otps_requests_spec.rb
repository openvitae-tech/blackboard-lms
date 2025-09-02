# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Api::V1::OtpsController, type: :request do
  let(:phone) { '9999999999' }
  let(:name) { 'Deepak' }
  let(:auth_token) { Rails.application.credentials[:api_token] }

  describe 'GET /api/v1/otps/generate' do
    it 'sends unauthorized response if auth_token is missing' do
      get '/api/v1/otps/generate', params: { phone: phone, name: name }
      expect(response).to have_http_status(:unauthorized)
    end

    it 'calls OtpService and returns otp in response' do
      service = instance_double(Auth::OtpService)
      allow(Auth::OtpService).to receive(:new).with(phone).and_return(service)
      allow(service).to receive(:generate_otp).and_return('1234')

      get '/api/v1/otps/generate', params: { phone: phone, name: name, auth_token: }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq({ 'otp' => '1234' })
      expect(service).to have_received(:generate_otp).once
    end
  end

  describe 'GET /api/v1/otps/verify' do
    context 'when otp is correct' do
      it 'sends unauthorized response if auth_token is missing' do
        get '/api/v1/otps/verify', params: { phone: phone, otp: '1234' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns success true with 200' do
        service = instance_double(Auth::OtpService)
        allow(Auth::OtpService).to receive(:new).with(phone).and_return(service)
        allow(service).to receive(:verify_otp).with('1234').and_return(true)

        get '/api/v1/otps/verify', params: { phone: phone, otp: '1234', auth_token: }

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body).to eq({ 'success' => true })
        expect(service).to have_received(:verify_otp).with('1234')
      end
    end

    context 'when otp is incorrect' do
      it 'sends unauthorized response if auth_token is incorrect' do
        get '/api/v1/otps/verify', params: { phone: phone, otp: '1234', auth_token: 'safdasfasdfsdaf' }
        expect(response).to have_http_status(:unauthorized)
      end

      it 'returns success false with 400' do
        service = instance_double(Auth::OtpService)
        allow(Auth::OtpService).to receive(:new).with(phone).and_return(service)
        allow(service).to receive(:verify_otp).with('0000').and_return(false)

        get '/api/v1/otps/verify', params: { phone: phone, otp: '0000', auth_token: }

        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body).to eq({ 'success' => false })
        expect(service).to have_received(:verify_otp).with('0000')
      end
    end
  end
end
