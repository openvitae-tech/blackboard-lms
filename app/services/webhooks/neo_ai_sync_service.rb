# frozen_string_literal: true

module Webhooks
  class NeoAiSyncService
    include Singleton

    def sync_course(course_id)
      response = get_course_data(course_id)

      raise I18n.t('neo_ai.course_fetch_failed', status: response.status, body: response.body) unless response.success?

      JSON.parse(response.body)
    end

    private

    def get_course_data(course_id)
      url = "#{APP_CONFIG.neo_ai_get_course_url}/#{course_id}"
      token = generate_token

      connection = Faraday.new(url: url) do |f|
        f.options.timeout = 10
        f.options.open_timeout = 5
        f.headers['Authorization'] = "Bearer #{token}"
      end
      connection.get(url)
    end

    def generate_token
      url = APP_CONFIG.neo_ai_token_url
      client_secret = Rails.application.credentials.dig(:neo_ai, :api_access_token)
      response = Faraday.new(url: url) do |f|
        f.options.timeout = 10
        f.options.open_timeout = 5
        f.headers['x-client-secret'] = client_secret
      end.get(url)

      raise I18n.t('neo_ai.token_request_failed', status: response.status, body: response.body) unless response.success?

      token = JSON.parse(response.body)['access_token']
      raise I18n.t('neo_ai.token_missing_access_token') if token.blank?

      token
    end
  end
end
