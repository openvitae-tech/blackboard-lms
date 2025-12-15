# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :set_dashboard_params, only: :index

  def index
    authorize :dashboard

    service = DashboardService.instance
    @dashboard = service.build_dashboard_for(@team, @duration)
  end

  private

  def set_dashboard_params
    team_id = params[:team_id].present? ? params[:team_id] : current_user.team_id
    @team = Team.includes(sub_teams: :sub_teams).find(team_id)

    @duration = params[:duration].present? ? params[:duration] : ::Dashboard::VALID_DURATIONS.first[0]
  end
end
