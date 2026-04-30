# frozen_string_literal: true

module DashboardsHelper
  MenuItem = Struct.new(:label, :link, :data)
  def duration_menu_for(team)
    @duration_menu_for ||= Dashboard::VALID_DURATIONS.map do |key, value|
      MenuItem.new(value, dashboard_path(duration: key.to_s, team_id: team.id))
    end + [MenuItem.new('Custom date', '#', { action: 'click->custom-date#open' })]
  end

  def duration_menu_for_member(team, member, origin: nil)
    Dashboard::VALID_DURATIONS.map do |key, value|
      MenuItem.new(value,
                   team_member_profile_dashboards_path(duration: key.to_s, team_id: team.id, user_id: member.id,
                                                       origin: origin))
    end + [MenuItem.new('Custom date', '#', { action: 'click->custom-date#open' })]
  end

  def selected_label(duration)
    return 'Custom date' if duration.is_a?(Range)

    Dashboard::VALID_DURATIONS[duration.to_sym] || Dashboard::VALID_DURATIONS[:last_7_days].to_s
  end

  def period_label(duration)
    days = (duration.end - duration.begin).to_i / 1.day
    case days
    when 0..7 then 'this week'
    when 8..14 then 'last 2 weeks'
    when 15..31 then 'this month'
    else 'this period'
    end
  end

  def days_remaining(deadline)
    ((deadline - Time.current) / 1.day).ceil
  end

  def scale_series(series, max_limit)
    return {} if series.blank?

    max_value = series.values.max || 0
    scale_factor = max_value > max_limit ? max_limit.to_f / max_value : 1
    series.transform_values { |v| (v * scale_factor).round }
  end
end
