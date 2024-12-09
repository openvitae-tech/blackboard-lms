# frozen_string_literal: true

class LessonViewsQuery < AppQuery
  def call
    run_query do
      Event.where(
        name: 'lesson_viewed',
        partner_id: @partner_id,
        created_at: @duration
      ).order(:id)
    end
  end
end