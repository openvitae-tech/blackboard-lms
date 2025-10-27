# frozen_string_literal: true

class AppConfigService
  include Singleton

  CONFIG = Rails.application.config_for(:app_config).with_indifferent_access

  def external_video_hosting?
    CONFIG[:external_video_hosting]
  end

  def sidekiq_auth_enabled?
    CONFIG[:sidekiq_auth_enabled]
  end
end
