# frozen_string_literal: true

module Api
  module Internal
    class ClassroomKitsController < ApplicationController
      skip_before_action :verify_authenticity_token

      FIXTURES_PATH = File.expand_path('../../../../../fixtures/api', __dir__)

      # POST /api/internal/classroom_kits
      def create
        kit_id = "stub-kit-#{SecureRandom.hex(4)}"
        Rails.cache.write("kit_started_at_#{kit_id}", Time.current, expires_in: 10.minutes)
        render json: { kit_id: kit_id }
      end

      # GET /api/internal/classroom_kits/:id/generation_status
      # Time-based phase cycling so it works correctly via server-to-server requests.
      def generation_status
        started_at = Rails.cache.fetch("kit_started_at_#{params[:id]}", expires_in: 10.minutes) { Time.current }
        elapsed = Time.current - started_at

        fixture = if elapsed < 6
                    'kit_generation_status_uploading'
                  else
                    'kit_generation_status_crafting'
                  end

        render json: File.read(File.join(FIXTURES_PATH, "#{fixture}.json"))
      end
    end
  end
end
