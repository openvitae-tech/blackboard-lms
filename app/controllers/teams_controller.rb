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
  end

  def create
    service = TeamManagementService.instance
    parent_team = Team.find create_team_params[:parent_team_id]

    @team = Team.new(create_team_params)

    if service.create_team(@team, current_user.learning_partner)
      redirect_to team_path(parent_team)
    else
      render 'new'
    end
  end

  def edit
    @team = Team.find params[:id]
  end

  def update
    team = Team.find(params[:id])
    service = TeamManagementService.instance
    service.update_team(team, update_team_params)
    redirect_to team
  end

  private

  def create_team_params
    params.require(:team).permit(:name, :banner, :parent_team_id)
  end

  def update_team_params
    params.require(:team).permit(:name, :banner)
  end
end
