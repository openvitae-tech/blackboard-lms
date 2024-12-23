# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show]

  def show
    authorize @user
    service = UserStatisticsService.instance
    @user_stats = service.build_stats_for(current_user)
  end

  private

    def set_user
      @user = User.find(params[:id])
      @enrolled_courses = @user.courses.includes(:enrollments)
    end
end
