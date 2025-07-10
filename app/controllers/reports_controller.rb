# frozen_string_literal: true

class ReportsController < ApplicationController
  def new
    authorize :report
    @team = Team.find params[:team_id]
    @report = Report.new(name: "New report", team_id: @team.id, generated_by: current_user.id)
  end

  def create
    authorize :report
    @team = Team.find(create_reports_params[:team_id])
    @report = Report.new(create_reports_params)

    @report.name = "Report #{create_reports_params[:start_date]}-#{create_reports_params[:end_date]}"
    @report.team = @team
    @report.generator = current_user
    @report.report_type = Report::TEAM_REPORT

    if @report.save
      flash.now[:success] = I18n.t('reports.available_soon')
    else
      render :new
    end
  end

  def show
    authorize :report
  end

  def create_reports_params
    params.require(:report).permit(:team_id, :start_date, :end_date)
  end
end