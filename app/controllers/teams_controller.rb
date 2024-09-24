# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :authenticate_user!

  def new
    @team = Team.new(parent_team_id: params[:parent_team_id])
  end

  def show
    @team = Team.find params[:id]
    @learning_partner = current_user.learning_partner
    @members = @team.users
    @teams = Team.all
  end

  def create
    service = TeamManagementService.instance

    return unless team_params[:parent_team_id].present? && Team.exists?(team_params[:parent_team_id])

    service.create_team!(team_params, current_user.learning_partner)
  end

  def edit
    @team = Team.find params[:id]
  end

  def update
    team = Team.find(params[:id])
    service = TeamManagementService.instance
    service.update_team!(team, team_params)
  end

  private

  def team_params
    params.require(:team).permit(:name, :banner, :parent_team_id)
  end
end
