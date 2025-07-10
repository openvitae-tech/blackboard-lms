# frozen_string_literal: true

module Reporting
  class TeamReportService
    attr_reader :report

    def initialize(report)
      @report = report
    end

    def generate; end
  end
end
