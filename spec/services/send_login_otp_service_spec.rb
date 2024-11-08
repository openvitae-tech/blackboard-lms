# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SendLoginOtpService do
  let(:user) { create :user, :learner }

  describe '#send_sms' do
    before do
      stub_msg91_sms_api(user.phone, user.otp)
    end

    it 'should_send_otp_as_sms' do
      response = send_login_otp_service(user.phone, user).process

      expect(response).to be_a(Net::HTTPOK)
    end
  end

  private

  def send_login_otp_service(mobile_number, user)
    SendLoginOtpService.new(mobile_number, user)
  end
end
