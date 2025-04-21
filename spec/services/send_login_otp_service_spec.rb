# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendLoginOtpService do
  let(:user) { create :user, :learner }

  describe '#send_sms' do
    before do
      template_id = Rails.application.credentials.dig(:fast2sms, :template, :otp)
      user.set_otp!
      stub_fast2sms_api(user.phone, password_decrypter(user.otp), template_id)
    end

    it 'should_send_otp_as_sms' do
      response = send_login_otp_service(user.phone, password_decrypter(user.otp)).process
      expect(response).to be_a(Net::HTTPOK)
    end
  end

  private

  def send_login_otp_service(mobile_number, otp)
    SendLoginOtpService.new(mobile_number, otp)
  end

  def password_decrypter(otp)
    password_verifier = Rails.application.message_verifier(Rails.application.credentials[:password_verifier])

    password_verifier.verify(otp)
  end
end
