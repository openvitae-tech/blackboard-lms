# frozen_string_literal: true

require Rails.root.join('app/services/event_service.rb').to_path

EVENT_LOGGER = EventService.instance

REDIS_CLIENT = RedisClient
               .config(url: Rails.application.credentials.dig(:redis, :url), reconnect_attempts: 2)
               .new_pool(timeout: 5, size: Integer(ENV.fetch('RAILS_MAX_THREADS', 5)))

STATIC_ASSETS = {
  team_banner: 'team_banner_placeholder.jpeg',
  course_banner: 'course_banner_placeholder.jpeg',
  hotel_logo: 'hotel_logo_placeholder.jpg',
  banner_desktop: 'banner_placeholder.png',
  banner_mobile: 'banner_placeholder_mobile.png',
  logo: 'logo_place_holder.png'
}.freeze

FLAG_LOGIN_WITH_OTP = true
