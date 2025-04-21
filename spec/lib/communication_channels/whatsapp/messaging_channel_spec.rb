# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommunicationChannels::Whatsapp::MessagingChannel do
  subject { described_class.new }

  let(:user) { create :user, :learner, communication_channels: ['whatsapp'] }

  describe 'send_message' do
    before do
      stub_whatsapp_api(user.phone, 'test_template')
    end

    it 'able to send whatsapp message' do
      response = subject.send_message(user.phone, 'test_template')
      expect(response).to be_a(Net::HTTPOK)
    end
  end
end
