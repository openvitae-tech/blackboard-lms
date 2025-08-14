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

  def scale_time_spent_series(series)
    return {} if series.blank?

    max_value = series.values.max || 0
    scale_factor = max_value > 120 ? 120.0 / max_value : 1
    series.transform_values { |v| (v * scale_factor).round }
  end
end
