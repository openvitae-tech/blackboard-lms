# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: [:show, :deactivate, :confirm_deactivate]

  def show
    authorize @user
    @enrolled_courses = @user.courses.includes(:enrollments)
    service = UserStatisticsService.instance
    @user_stats = service.build_stats_for(current_user)
  end

  def deactivate
  end

  def confirm_deactivate
    if @user.deactivate
      flash.now[:success] = I18n.t('user.deactivate')
    else
      flash.now[:error] = I18n.t('user.deactivate_failed')
    end
  end

  private

    def set_user
      @user = User.find(params[:id])
    end
end
