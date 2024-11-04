# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UploadVideoToVimeoJob do
  after(:each) do
    Sidekiq::Job.clear_all
  end

  describe '#perform_async' do
    it 'ensures the job is enqueued' do
      Sidekiq::Testing.fake! do
        expect do
          UploadVideoToVimeoJob.perform_async
        end.to change(UploadVideoToVimeoJob.jobs, :size).by(1)
      end
    end
  end
end
