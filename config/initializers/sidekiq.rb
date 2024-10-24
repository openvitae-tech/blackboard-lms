# frozen_string_literal: true

require 'sidekiq'
require 'sidekiq-cron'
require 'sidekiq-unique-jobs'

if Rails.env.test?
  require 'sidekiq/testing'
  Sidekiq::Testing.inline!
end

Sidekiq.logger.level = Logger::WARN if Rails.env.test?

Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.credentials.dig(:redis, :url), size: 9, reconnect_attempts: 2,
                   network_timeout: 10 }

  schedule_file = 'config/scheduled_jobs.yml'
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file, aliases: true)[Rails.env] ||
                                      YAML.load_file(schedule_file, aliases: true)
  end

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.credentials.dig(:redis, :url), size: 1,
                   reconnect_attempts: 2,
                   network_timeout: 10 }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
