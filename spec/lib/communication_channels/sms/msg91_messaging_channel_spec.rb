# frozen_string_literal: true

RSpec.describe CommunicationChannels::Sms::Msg91MessagingChannel do
  subject { described_class.new }

  let(:user) { create :user, :learner }

  describe '#send_message' do
    before do
      stub_msg91_sms_api("#{user.country_code}#{user.phone}", { 'var1' => '1234' }, '123456')
    end

    it 'able to send sms' do
      response = subject.send_message("#{user.country_code}#{user.phone}", { 'var1' => '1234' }, '123456')
      expect(response).to be_a(Net::HTTPOK)
    end

    it 'does not send sms if message id is invalid' do
      response = subject.send_message(user.phone, 'test value', '')
      expect(response).to be_nil
    end

    it 'when SMS sending fails' do
      http_response = instance_double(Net::HTTPResponse, is_a?: false, code: '400', body: 'Bad Request')

      allow(Sentry).to receive(:capture_message)
      allow(subject).to receive(:dispatch_sms_request).and_return(http_response)

      subject.send_message(user.phone, 'test value', 'template123')

      expect(Sentry).to have_received(:capture_message).with(
        'Failed to send SMS',
        level: :error,
        extra: { status: '400', body: 'Bad Request' }
      )
    end
  end
end
