# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserChannelNotifierService do
  subject { described_class.instance }

  let(:user) { create :user, :learner, communication_channels: %w[whatsapp] }

  after do
    Sidekiq::Job.clear_all
  end

  describe 'notify_user' do
    it 'enqueues the WhatsApp message job' do
      Sidekiq::Testing.fake! do
        expect do
          subject.notify_user(user, ChannelMessageTemplates.new.course_assigned_template)
        end.to change(CommunicationChannels::SendWhatsappMessageJob.jobs, :size).by(1)
      end
    end

    it 'enqueues the sms job' do
      new_user = create :user, :learner
      parameters = { sms_variables_values: 'test value' }
      Sidekiq::Testing.fake! do
        expect do
          subject.notify_user(new_user, ChannelMessageTemplates.new.course_assigned_template, parameters)
        end.to change(CommunicationChannels::SendSmsJob.jobs, :size).by(1)
      end
    end
  end
end
