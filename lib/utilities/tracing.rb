# frozen_string_literal: true

# Trading module to track a sequence of operations
module Utilities
  # Utility module to trace specific sections of code
  module Tracing
    # Data class for storing trace data
    class TraceData
      attr_reader :name, :trace_id, :start_time

      def initialize(name)
        @name = name
        @trace_id = SecureRandom.uuid
        @start_time = time_in_milliseconds
      end

      def duration
        end_time = time_in_milliseconds
        (end_time - start_time).round(2)
      end

      private

      def time_in_milliseconds
        Process.clock_gettime(Process::CLOCK_MONOTONIC) * 1000
      end
    end

    def with_tracing(name = '', logger = Rails.logger, &)
      trace = TraceData.new(name)
      logger.info "Trace: #{trace.trace_id} #{self.class.name} #{trace.name}"
      result = yield(trace)
      logger.info "Trace: #{trace.trace_id} #{self.class.name} Duration(ms): #{trace.duration} #{trace.name}"
      result
    rescue StandardError => e
      logger.info(
        "Trace: #{trace&.trace_id} #{self.class.name} Duration(ms): #{trace&.duration} #{trace&.name} Error: #{e}"
      )
      raise e
    end
  end
end
