# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::OneTimerTasksController', type: :request do
  let(:task) { :generate_transcripts_for_existing_videos }
  let(:mock_rake_task) { instance_double(Rake::Task, invoke: true) }
  let(:auth_token) { Rails.application.credentials[:api_token] }

  before do
    allow(Rails.application).to receive(:load_tasks)
    allow(Rake::Task).to receive(:[]).with("one_timer:#{task}")
                                     .and_return(mock_rake_task)
    Rails.cache.clear
  end

  describe 'GET one_timer_tasks/one_timer' do
    it 'invokes the rake task and writes to cache' do
      allow(Rails.cache).to receive(:write)

      post run_tasks_api_v1_one_timer_task_path, params: { auth_token: }

      expect(response).to have_http_status(:ok)
      json = response.parsed_body

      expect(json['message']).to eq('Tasks processed')
      expect(json['details']).to include(
        a_hash_including(
          'task' => task.to_s,
          'status' => 'Executed'
        )
      )
      expect(Rails.cache).to have_received(:write)
        .with(task, task, expires_in: 1.hour)
    end

    context 'when the task has already been run recently' do
      before do
        Rails.cache.write(task, task.to_json, expires_in: 1.hour)
        allow(Rails.cache).to receive(:write)
      end

      it 'skips execution and returns skipped status' do
        post run_tasks_api_v1_one_timer_task_path, params: { auth_token: }

        expect(response).to have_http_status(:ok)

        body = response.parsed_body
        details = body['details'].first

        expect(details['task']).to eq(task.to_s)
        expect(details['status']).to eq('Task has been (skipped) as it was recently executed')
        expect(mock_rake_task).not_to have_received(:invoke)
      end
    end
  end
end
