# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GenerateCourseCertificateJob do
  let(:learner) { create :user, :learner }
  let(:learning_partner) { create(:learning_partner) }
  let(:course) { create :course }
  let(:certificate_template) { create(:certificate_template, learning_partner:) }

  after do
    Sidekiq::Job.clear_all
  end

  describe '#perform_async' do
    it 'ensures the job is enqueued' do
      Sidekiq::Testing.fake! do
        expect do
          described_class.perform_async(course.id, learner.id, certificate_template.id)
        end.to change(described_class.jobs, :size).by(1)
      end
    end
  end
end
