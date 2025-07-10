# frozen_string_literal: true

class GenerateReportJob < BaseJob
  def perform(report_id)
    with_tracing "report-#{report_id}" do
      @report = Report.find report_id
      notify_user
    end
  end

  def notify_user
    return if @report.generator.blank?

    NotificationService.notify(
      @report.generator,
      'Download report',
      'Your report is ready to download',
      link: Rails.application.routes.url_helpers.report_path(@report)
    )
  end
end
