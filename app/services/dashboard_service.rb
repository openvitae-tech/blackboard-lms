# frozen_string_literal: true

class DashboardService
  include Singleton

  def build_dashboard_for(team, duration)
    Dashboard.new(team, duration)
  end
end
