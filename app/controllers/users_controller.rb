# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user
  def show
    authorize @user
    @enrolled_courses = @user.courses.includes(:tags, :banner_attachment)
    service = UserStatisticsService.instance
    @user_stats = service.build_stats_for(@user)
  end

  def deactivate
    authorize @user
  end

  def confirm_deactivate
    authorize @user

    service = UserManagementService.instance

    if service.deactivate(current_user, @user)
      Teams::UpdateTotalMembersCountService.instance.update_count(@user.team)
      flash.now[:success] = I18n.t('user.deactivate')
    else
      flash.now[:error] = I18n.t('user.deactivate_failed')
    end
  end

  def activate
    authorize @user
  end

  def confirm_activate
    authorize @user

    service = UserManagementService.instance

    if service.activate(current_user, @user)
      Teams::UpdateTotalMembersCountService.instance.update_count(@user.team)
      flash.now[:success] = I18n.t('user.activate')
    else
      flash.now[:error] = I18n.t('user.activate_failed')
      flash.now[:error] = I18n.t('user.deactivate_failed')
    end
  end

  def destroy
    authorize @user
    @user.destroy
    Teams::UpdateTotalMembersCountService.instance.update_count(@user.team)
    redirect_to @user.team, notice: I18n.t('user.deleted') and return
  end

  def change_role
    authorize @user
  end

  def confirm_change_role
    authorize @user, :change_role?
    new_role = change_role_params[:role]
    if current_user.selectable_roles(@user.team).include?(new_role)
      @user.role = new_role
      if @user.save
        flash.now[:success] = I18n.t('user.role_updated')
      else
        flash.now[:error] = I18n.t('user.role_update_failed')
      end
    else
      flash.now[:error] = I18n.t('user.role_update_failed')
    end
  end

  def select_roles
    authorize @user, :change_role?
    @user.role = params[:selected]
  end

  def change_team
    authorize @user
    sub_teams = current_user.team.sub_teams
    @teams = sub_teams.any? ? [current_user.team] + sub_teams : []
  end


  def confirm_change_team
    authorize @user, :change_team?

    team_id = change_team_params[:team_id]
    if change_team_params[:team_id].blank?
      handle_missing_team_id and return
    end

    prev_team = @user.team
    @user.update!(team_id: team_id)
    update_team_member_counts(prev_team)
    flash.now[:success] = "Team changed successfully"
  end

  private

    def set_user
      @user = User.find(params[:id])
    end

    def change_team_params
      params.require(:user).permit(:team_id)
    end

    def change_role_params
      params.require(:user).permit(:role)
    end

    def handle_missing_team_id
      @user.errors.add(:team_id, "must be selected")
      @teams = current_user.team.sub_teams
      render :change_team, status: :unprocessable_entity
    end

    def update_team_member_counts(prev_team)
      new_team = @user.team
      if prev_team != new_team
        Teams::UpdateTotalMembersCountService.instance.update_count(prev_team)
      end
      Teams::UpdateTotalMembersCountService.instance.update_count(new_team)
    end
end
