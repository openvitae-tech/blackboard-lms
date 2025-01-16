# frozen_string_literal: true

class TeamsController < ApplicationController
  before_action :set_team, only: %i[show edit update]
  before_action :set_parent_team, only: :create

  def new
    authorize :team
    @team = Team.new(parent_team_id: params[:parent_team_id])
  end

  def show
    authorize @team
    @learning_partner = current_user.learning_partner
    @members = @team.members
  end

  def create
    authorize @parent_team

    service = TeamManagementService.instance
    @team = Team.new(create_team_params)

    if service.create_team(@team, current_user.learning_partner)
      flash.now[:success] = I18n.t('team.created')
    else
      render 'new'
    end
  end

  def edit
    authorize @team
  end

  def update
    authorize @team

    service = TeamManagementService.instance

    if service.update_team(@team, update_team_params)
      flash.now[:success] = I18n.t('team.updated')
    else
      render 'edit'
    end
  end

  private

  def create_team_params
    params.require(:team).permit(:name, :banner, :parent_team_id, :department)
  end

  def update_team_params
    params.require(:team).permit(:name, :banner, :department)
  end

  def set_team
    @team = Team.find(params[:id])
  end

  def set_parent_team
    @parent_team = Team.find(create_team_params[:parent_team_id])
  end
end
