# frozen_string_literal: true

class OnboardingInitiatedQuery < AppQuery
  def call
    run_query do
      query = Event.where(
        name: 'onboarding_initiated',

        ).order(:id)

      # partner id is optional for this query
      query = query.where(partner_id: @partner_id) if @partner_id.present?
      query = query.where(created_at: @duration) if @duration.present?

      query
    end
  end
end