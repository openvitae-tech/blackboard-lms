# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserChannelNotifierService do
  subject { described_class.instance }

  let(:user) { create :user, :learner, communication_channel: :whatsapp }

  describe 'notify_user' do
    it 'enqueues the WhatsApp message job' do
      Sidekiq::Testing.fake! do
        expect do
          subject.notify_user(user, 'test_template')
        end.to change(CommunicationChannels::SendWhatsappMessageJob.jobs, :size).by(1)
      end
    end
  end
end
