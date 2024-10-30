# frozen_string_literal: true

require Rails.root.join('app/services/event_service.rb').to_path

EVENT_LOGGER = EventService.instance

STATIC_ASSETS = {
  placeholders: {
    team_banner: 'team_banner_placeholder.jpeg',
  }
}.freeze
