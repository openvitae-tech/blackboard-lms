# frozen_string_literal: true

require Rails.root.join('app/services/event_service.rb').to_path

EVENT_LOGGER = EventService.instance
