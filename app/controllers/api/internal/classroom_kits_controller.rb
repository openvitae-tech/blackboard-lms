# frozen_string_literal: true

module Api
  module Internal
    class ClassroomKitsController < BaseController
      # POST /api/internal/classroom_kits
      # Stub — real implementation wired in Phase 3 backend work.
      def create
        kit_id = "stub-kit-#{SecureRandom.hex(4)}"
        Rails.cache.write("kit_started_at_#{kit_id}", Time.current, expires_in: 10.minutes)
        render json: { kit_id: kit_id }
      end

      # GET /api/internal/classroom_kits/:id/generation_status
      # Time-based phase cycling (session-free) so it works correctly via
      # server-to-server BlackboardClient requests:
      #   0–6 s  → uploading phase
      #   6–12 s → crafting phase
      #   12 s+  → completed
      def generation_status
        started_at = Rails.cache.fetch("kit_started_at_#{params[:id]}", expires_in: 10.minutes) { Time.current }
        elapsed = Time.current - started_at

        if elapsed < 6
          render json: { status: 'PENDING', stage: 'Uploading your document…', redirect_url: nil }
        else
          render json: { status: 'PENDING', stage: 'Crafting your kit structure…', redirect_url: nil }
        end
      end
    end
  end
end
