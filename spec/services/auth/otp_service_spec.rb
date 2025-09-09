# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Auth::OtpService, type: :service do
  let(:phone) { MobileNumber.new(value: '9999999999', country_code: AVAILABLE_COUNTRIES[:india][:code]) }
  let(:cache_key) { "otp:#{phone.value}" }
  let(:service) { described_class.new(phone, name: 'Deepak') }

  before do
    Rails.cache.clear
  end

  describe '#generate_otp' do
    context 'when no previous OTP exists' do
      it 'generates and stores a new otp in cache' do
        service.generate_otp
        cached = JSON.parse(Rails.cache.read(cache_key))

        expect(cached['otp']).to eq(User::TEST_OTP)
        expect(cached['name']).to eq('Deepak')
        expect(cached['attempts']).to eq(1)
      end
    end

    context 'when OTP exists with less than max attempts' do
      before do
        Rails.cache.write(cache_key, { otp: '1234', name: 'Deepak', attempts: 1 }.to_json, expires_in: 5.minutes)
      end

      it 'reuses existing otp and increments attempts' do
        service.generate_otp
        cached = JSON.parse(Rails.cache.read(cache_key))

        expect(cached['otp']).to eq('1234')
        expect(cached['attempts']).to eq(2)
      end
    end

    context 'when OTP has reached max attempts' do
      before do
        Rails.cache.write(cache_key, { otp: '1234', name: 'Deepak', attempts: 2 }.to_json, expires_in: 5.minutes)
      end

      it 'does not send another otp' do
        expect(service.generate_otp).to be_falsey
        cached = JSON.parse(Rails.cache.read(cache_key))

        expect(cached['attempts']).to eq(2) # unchanged
      end
    end
  end

  describe '#verify_otp' do
    before do
      Rails.cache.write(cache_key, { otp: '1234', name: 'Deepak', attempts: 1 }.to_json, expires_in: 5.minutes)
    end

    context 'with correct otp' do
      it 'creates a contact and returns truthy' do
        expect do
          service.verify_otp('1234')
        end.to change(ContactLead, :count).by(1)
      end
    end

    context 'with incorrect otp' do
      it 'returns false and does not create contact' do
        expect(service.verify_otp('9999')).to be(false)
        expect(ContactLead.count).to eq(0)
      end
    end
  end

  describe 'send_otp' do
    it 'sends OTP only in production' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('production'))
      notifier = instance_double(UserChannelNotifierService)
      allow(UserChannelNotifierService).to receive(:instance).and_return(notifier)
      allow(notifier).to receive(:notify_via_sms)

      service.send(:send_otp, '1234')

      expect(notifier).to have_received(:notify_via_sms).once
    end

    it 'does not send OTP in non-production' do
      allow(Rails).to receive(:env).and_return(ActiveSupport::StringInquirer.new('test'))
      notifier = instance_double(UserChannelNotifierService)
      allow(UserChannelNotifierService).to receive(:instance).and_return(notifier)
      allow(notifier).to receive(:notify_via_sms)

      service.send(:send_otp, '1234')

      expect(notifier).not_to have_received(:notify_via_sms)
    end
  end
end
