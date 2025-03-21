# frozen_string_literal: true

module DashboardsHelper
  MenuItem = Struct.new(:label, :link)
  def duration_menu_for(team)
    @duration_menu_for ||= Dashboard::VALID_DURATIONS.map do |key, value|
      MenuItem.new(value, dashboard_path(duration: key.to_s, team_id: team.id))
    end
  end

  def selected_label(duration)
    Dashboard::VALID_DURATIONS[duration.to_sym] || Dashboard::VALID_DURATIONS[:last_7_days].to_s
  end
end
