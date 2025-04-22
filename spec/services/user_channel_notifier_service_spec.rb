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
          subject.notify_user(user, ChannelMessageTemplate.new.course_assigned_template)
        end.to change(CommunicationChannels::SendWhatsappMessageJob.jobs, :size).by(1)
      end
    end
  end
end
