# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user

  def show
    authorize @user
    @enrolled_courses = @user.courses.includes(:enrollments)
    service = UserStatisticsService.instance
    @user_stats = service.build_stats_for(current_user)
  end

  def deactivate
    authorize @user
  end

  def confirm_deactivate
    authorize @user

    if @user.deactivate
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

    if @user.activate
      flash.now[:success] = I18n.t('user.activate')
    else
      flash.now[:error] = I18n.t('user.activate_failed')
      flash.now[:error] = I18n.t('user.deactivate_failed')
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end
end
