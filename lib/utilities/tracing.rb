# frozen_string_literal: true

# Trading module to track a sequence of operations
module Tracing
  # Data class for storing trace data
  class TraceData
    attr_accessor :trace_id, :start_time, :end_time

    def initialize
      @trace_id = SecureRandom.uuid
      @start_time = time_in_milliseconds
    end

    def duration
      @end_time ||= time_in_milliseconds
      (end_time - start_time).round(2)
    end

    private

    def time_in_milliseconds
      Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000
    end
  end

  def with_tracing(message = '', logger = Rails.logger, &block)
    trace = TraceData.new
    logger.info "Trace: #{trace.trace_id} #{self.class.name} #{message}"
    result = yield block
    logger.info "Trace: #{trace.trace_id} #{self.class.name} Duration(ms): #{trace.duration} #{message}"
    result
  end
end
