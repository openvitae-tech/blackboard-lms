# frozen_string_literal: true

RSpec.describe CommunicationChannels::Sms::MessagingChannel do
  subject { described_class.new }

  let(:user) { create :user, :learner }

  describe '#send_message' do
    before do
      stub_fast2sms_api(user.phone, 'test value', '123456')
    end

    it 'able to send sms' do
      response = subject.send_message(user.phone, 'test value', '123456')
      expect(response).to be_a(Net::HTTPOK)
    end

    it 'does not send sms if message id is invalid' do
      response = subject.send_message(user.phone, 'test value', '')
      expect(response).to be_nil
    end

    it 'when SMS sending fails' do
      http_response = instance_double(Net::HTTPResponse, is_a?: false, code: '400', body: 'Bad Request')

      allow(subject).to receive(:send_sms).and_return(http_response)
      expect(Sentry).to have_received(:capture_message).with(
        'Failed to send OTP via SMS',
        level: :error,
        extra: { status: '400', body: 'Bad Request' }
      )

      subject.send_message(user.phone, 'test value', 'template123')
    end
  end
end
