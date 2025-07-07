# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user

  def show
    authorize @user
    @enrolled_courses = @user.courses.includes(:enrollments)
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

  private

    def set_user
      @user = User.find(params[:id])
    end
end
