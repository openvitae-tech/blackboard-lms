# frozen_string_literal: true

class TimeSpentQuery < AppQuery
  def call
    run_query do
      Event.where(
        name: 'learning_time_spent',
        partner_id: @partner_id,
        created_at: @duration
      ).order(:id)
    end
  end
end