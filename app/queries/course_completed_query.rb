# frozen_string_literal: true

class CourseCompletedQuery < AppQuery
  def call
    run_query do
      Event.where(
        name: 'course_completed',
        partner_id: @partner_id,
        created_at: @duration
      ).order(:id)
    end
  end
end