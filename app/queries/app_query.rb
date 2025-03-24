# frozen_string_literal: true

require 'utilities/tracing'

class AppQuery
  include Utilities::Tracing

  attr_reader :results, :executed

  def initialize(partner_id, duration)
    @partner_id = partner_id
    @duration = duration
    @results = []
    @executed = false
  end

  def run_query
    # queries will be running only once
    return @results if executed?

    with_tracing "Query #{self.class.name}" do
      @results = yield
      @executed = true
      @results
    end
  end

  def executed?
    @executed
  end
end
