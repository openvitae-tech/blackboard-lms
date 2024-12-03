# frozen_string_literal: true

require Rails.root.join('app/services/event_service.rb').to_path

EVENT_LOGGER = EventService.instance

STATIC_ASSETS = {
  team_banner: 'team_banner_placeholder.jpeg',
  course_banner: 'course_banner_placeholder.jpeg',
  hotel_logo: 'hotel_logo_placeholder.jpg',
  banner_desktop: 'banner_placeholder.png',
  banner_mobile: 'banner_placeholder_mobile.png',
  logo: 'logo_place_holder.png'
}.freeze

FLAG_LOGIN_WITH_OTP = false
