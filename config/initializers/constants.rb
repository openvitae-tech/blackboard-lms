# frozen_string_literal: true

require "#{Rails.root}/app/services/event_service"

EVENT_LOGGER = EventService.instance
