# frozen_string_literal: true

module Api
  module V1
    class OneTimerTasksController < ApiController
      before_action :load_rake_tasks

      TASKS = [:upload_from_s3_to_vimeo]

      def run_tasks
        results = []
        TASKS.each do |task|
          if Rails.cache.read(task).blank?
            invoke_rake_task(task)
            results << { task: task, status: "Executed" }
          else
            results << { task: task, status: "Task has been (skipped) as it was recently executed" }
          end
        end
        render json: { message: "Tasks processed", details: results }, status: :ok
      end

      private

      def load_rake_tasks
        Rails.application.load_tasks
      end

      def invoke_rake_task(task)
        Rake::Task["one_timer:#{task}"].invoke
        Rails.cache.write(task, task, expires_in: 1.hour)
      end
    end
  end
end
