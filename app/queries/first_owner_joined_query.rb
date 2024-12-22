# frozen_string_literal: true

class FirstOwnerJoinedQuery < AppQuery
  def call
    run_query do
      query = Event.where(
        name: 'first_user_joined',
        partner_id: @partner_id,
        ).order(:id)

      query = query.where(created_at: @duration) if @duration.present?

      query
    end
  end
end