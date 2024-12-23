# frozen_string_literal: true

class UserJoinedQuery < AppQuery
  def call
    run_query do
      query = Event.where(
        name: 'user_joined',
        partner_id: @partner_id,
        ).order(:id)

      query = query.where(created_at: @duration) if @duration.present?

      query
    end
  end
end