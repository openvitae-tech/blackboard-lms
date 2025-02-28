# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MonthlyInvoiceCalculatorJob do
  let(:user) { create :user, :admin }

  after do
    Sidekiq::Job.clear_all
  end

  it 'ensures the job is enqueued' do
    Sidekiq::Testing.fake! do
      expect do
        described_class.perform_async
      end.to change(described_class.jobs, :size).by(1)
    end
  end
end
