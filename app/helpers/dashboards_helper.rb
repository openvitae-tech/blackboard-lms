# frozen_string_literal: true

module DashboardsHelper
  MenuItem = Struct.new(:label, :link)
  def duration_menu_for(team)
    @dashboard_menu ||= Dashboard::VALID_DURATIONS.map { |key, value| MenuItem.new(value, dashboard_path(duration: key.to_s, team_id: team.id)) }
  end

  def selected_label
    Dashboard::VALID_DURATIONS[@duration.to_sym] || Dashboard::VALID_DURATIONS[:last_7_days].to_s
  end
end