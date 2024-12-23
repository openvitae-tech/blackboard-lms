# frozen_string_literal: true

class OnboardingCompletedQuery < AppQuery
  def call
    run_query do
      query = Event.where(
        name: 'onboarding_completed',
        ).order(:id)

      query = query.where(partner_id: @partner_id) if @partner_id.present?
      query = query.where(created_at: @duration) if @duration.present?

      query
    end
  end
end