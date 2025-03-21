# frozen_string_literal: true

# Count total number of enrolled users for a particular partner for all available courses
class UserEnrolledQuery < AppQuery
  def call
    run_query do
      query = Event.where(
        name: 'course_enrolled',
        partner_id: @partner_id
      ).order(:id)

      query = query.where(created_at: @duration) if @duration.present?

      query
    end
  end
end
