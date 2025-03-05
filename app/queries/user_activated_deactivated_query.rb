# frozen_string_literal: true

class UserActivatedDeactivatedQuery < AppQuery
  def call
    run_query do
      Event.where(
        partner_id: @partner_id,
        created_at: @duration,
        name: %w[user_activated user_deactivated]
      ).order(:created_at)
    end
  end
end
