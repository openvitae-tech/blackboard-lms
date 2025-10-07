# frozen_string_literal: true

APP_CONFIG = Rails.application.config_for(:app_config).with_indifferent_access

def external_video_hosting?
  APP_CONFIG[:external_video_hosting]
end
