# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommunicationChannels::SendWhatsappMessageJob do
  after do
    Sidekiq::Job.clear_all
  end

  describe '#perform_async' do
    it 'ensures the job is enqueued' do
      Sidekiq::Testing.fake! do
        expect do
          described_class.perform_async('test_template', '123456789')
        end.to change(described_class.jobs, :size).by(1)
      end
    end
  end
end
