# frozen_string_literal: true

class TeamReportQuery < AppQuery
  def initialize(partner_id, duration, user_ids)
    super(partner_id, duration)
    @user_ids = user_ids
  end

  def call
    run_query do
      query = Event.where(
        name: event_names,
        partner_id: @partner_id
      ).order(:id)

      query = query.where(created_at: @duration) if @duration.present?

      query
    end
  end

  private

  def event_names
    [
      Event::LEARNING_TIME_SPENT,
      Event::COURSE_STARTED,
      Event::COURSE_COMPLETED
    ].freeze
  end
end
