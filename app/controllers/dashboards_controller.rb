class DashboardsController < ApplicationController
  before_action :authenticate_user!
  def index
    service = UserStatisticsService.instance
    @user_stats = service.build_stats_for(current_user)
  end
end