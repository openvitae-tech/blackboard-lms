# frozen_string_literal: true

class TimeSpentQuery < AppQuery
  def call
    run_query do
      query = Event.where(
        name: 'learning_time_spent',
        partner_id: @partner_id,
      ).order(:id)

      query = query.where(created_at: @duration) if @duration.present?

      query
    end
  end
end