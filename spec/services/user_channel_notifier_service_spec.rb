# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserChannelNotifierService do
  subject { described_class.instance }

  let(:user) { create :user, :learner, communication_channel: :whatsapp }

  describe 'notify_user' do
    it 'enqueues the WhatsApp message job' do
      Sidekiq::Testing.fake! do
        expect do
          subject.notify_user(user, template: 'test_template')
        end.to change(CommunicationChannels::SendWhatsappMessageJob.jobs, :size).by(1)
      end
    end

    it 'enqueues the sms job' do
      new_user = create :user, :learner
      parameters = { sms_variables_values: 'test value', sms_message_id: '12345' }
      Sidekiq::Testing.fake! do
        expect do
          subject.notify_user(new_user, template: 'test_template', parameters:)
        end.to change(CommunicationChannels::SendSmsJob.jobs, :size).by(1)
      end
    end
  end
end
