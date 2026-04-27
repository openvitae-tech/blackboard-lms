# frozen_string_literal: true

NEO_AI_BASE_URL = Rails.application.credentials.dig(:neo_ai, :base_url)
NEO_AI_CLIENT_SECRET = Rails.application.credentials.dig(:neo_ai, :client_secret)
NEO_AI_PARTNER_ID = Rails.application.credentials.dig(:neo_ai, :partner_id)
