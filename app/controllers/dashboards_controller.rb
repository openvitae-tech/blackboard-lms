# frozen_string_literal: true

class DashboardsController < ApplicationController
  before_action :authenticate_user!
  def index
    authorize :dashboard
    service = UserStatisticsService.instance
    @user_stats = service.build_stats_for(current_user)
  end
end
