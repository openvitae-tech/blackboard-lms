# frozen_string_literal: true

class TimeSpentQuery
  attr_reader :results, :executed

  def initialize(partner_id, duration)
    @partner_id = partner_id
    @duration = duration
    @results = []
    @executed = false
  end

  def call
    # queries will be running only once
    return @results if executed?

    @results = Event.where(
      name: 'learning_time_spent',
      partner_id: @partner_id,
      created_at: @duration
    ).order(:id)

    @executed = true

    @results
  end

  def executed?
    @executed
  end
end