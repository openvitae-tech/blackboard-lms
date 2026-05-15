# frozen_string_literal: true

require_relative 'concerns/dashboard_engagement'
require_relative 'concerns/dashboard_team'
require_relative 'concerns/dashboard_activity'

# PORO class for Dashboard
class Dashboard
  VALID_DURATIONS = {
    last_7_days: 'Last 7 days',
    last_14_days: 'Last 14 days',
    last_30_days: 'Last 30 days',
    last_month: 'Last month'
  }.freeze

  include DashboardEngagement
  include DashboardTeam
  include DashboardActivity

  attr_reader :team, :duration

  def initialize(team, duration)
    @team = team
    @duration = to_duration(duration)
    @team_and_subteam_ids = []
  end

  def time_spent_series
    events = filter_by_teams(time_spent_query.call)
    events.group_by { |e| to_grouping_key(e) }.transform_values do |vals|
      vals.map(&:data).sum { |v| v['time_spent'].to_i } / 60
    end
  end

  def total_time_spent_metric
    events = filter_by_teams(time_spent_query.call)
    events.map(&:data).map { |v| v['time_spent'].to_i }.reduce(&:+) || 0
  end

  def average_time_spent_metric
    events = filter_by_teams(time_spent_query.call)
    count = user_count(events)
    return 0 if count.zero?

    total_time_spent_metric / count
  end

  def active_learners_count
    user_count(filter_by_teams(time_spent_query.call))
  end

  def certificates_count
    CourseCertificate.joins(:user)
                     .where(users: { team_id: team_and_subteam_ids(@team) }, issued_at: @duration)
                     .count
  end

  def active_course_count_metric
    events = filter_by_teams(time_spent_query.call)
    events.map(&:data).pluck('course_id').uniq.count || 0
  end

  def team_score_metric
    # TODO: need better implementation
    @team.score
  end

  def total_course_time_metric
    events = filter_by_teams(time_spent_query.call)
    durations = Course.pluck(:id, :duration).to_h
    events.group_by(&:user_id).sum do |_, user_events|
      user_events.map(&:data).pluck('course_id').uniq.sum { |id| durations[id] }
    end
  end

  def completion_percent_metric
    return 0 if total_course_time_metric < 1

    (total_time_spent_metric / total_course_time_metric.to_f * 100).round
  end

  def lesson_views_series
    event_count_series(lesson_viewed_query)
  end

  def course_enrolled_series
    event_count_series(user_enrolled_query)
  end

  def course_started_series
    event_count_series(course_started_query)
  end

  def course_completed_series
    event_count_series(course_completed_query)
  end

  def falling_behind_learners
    Enrollment
      .joins(:user)
      .where(users: { team_id: @team.team_hierarchy_ids })
      .where.not(users: { role: [User::ADMIN, User::SUPPORT] })
      .where(course_completed: false)
      .where('deadline_at IS NOT NULL AND deadline_at < ?', 7.days.from_now)
      .includes(:user, :course)
      .order(:deadline_at)
  end

  def falling_behind_count
    falling_behind_learners.count
  end

  def active_learners_delta
    active_learners_count - previous_active_learners_count
  end

  def completion_percent_delta
    completion_percent_metric - previous_completion_percent_metric
  end

  def average_time_spent_delta
    average_time_spent_metric - previous_average_time_spent_metric
  end

  def certificates_delta
    certificates_count - previous_certificates_count
  end

  def user_count(events)
    events.collect(&:user_id).uniq.count
  end

  private

  def event_count_series(query)
    events = filter_by_teams(query.call)
    events.group_by { |e| to_grouping_key(e) }.transform_values(&:count)
  end

  def previous_duration
    @previous_duration ||= begin
      period_length = @duration.end - @duration.begin
      (@duration.begin - period_length)..@duration.begin
    end
  end

  def previous_active_learners_count
    user_count(previous_time_spent_events)
  end

  def previous_completion_percent_metric
    return 0 if previous_total_course_time < 1

    (previous_total_time_spent / previous_total_course_time.to_f * 100).round
  end

  def previous_average_time_spent_metric
    count = user_count(previous_time_spent_events)
    return 0 if count.zero?

    previous_total_time_spent / count
  end

  def previous_time_spent_events
    @previous_time_spent_events ||= begin
      events = TimeSpentQuery.new(@team.learning_partner_id, previous_duration).call
      filter_by_teams(events)
    end
  end

  def previous_total_time_spent
    previous_time_spent_events.map(&:data).map { |v| v['time_spent'].to_i }.reduce(&:+) || 0
  end

  def previous_total_course_time
    durations = Course.pluck(:id, :duration).to_h
    previous_time_spent_events.group_by(&:user_id).sum do |_, user_events|
      user_events.map(&:data).pluck('course_id').uniq.sum { |id| durations[id] }
    end
  end

  def previous_certificates_count
    CourseCertificate.joins(:user)
                     .where(users: { team_id: team_and_subteam_ids(@team) }, issued_at: previous_duration)
                     .count
  end

  def to_duration(duration)
    return duration if duration.is_a?(Range)

    case duration
    when 'last_14_days' then 14.days.ago.beginning_of_day..Time.zone.now
    when 'last_30_days' then 30.days.ago.beginning_of_day..Time.zone.now
    when 'last_month' then 2.months.ago.all_month
    else
      7.days.ago.beginning_of_day..Time.zone.now
    end
  end

  def to_grouping_key(event)
    [event.created_at.day.to_s.rjust(2, '0'), Date::MONTHNAMES[event.created_at.month][0..2]].join(' ')
  end

  def time_spent_query
    @time_spent_query ||= TimeSpentQuery.new(@team.learning_partner_id, @duration)
  end

  def lesson_viewed_query
    @lesson_viewed_query ||= LessonViewsQuery.new(@team.learning_partner_id, @duration)
  end

  def user_enrolled_query
    @user_enrolled_query ||= UserEnrolledQuery.new(@team.learning_partner_id, @duration)
  end

  def course_started_query
    @course_started_query ||= CourseStartedQuery.new(@team.learning_partner_id, @duration)
  end

  def course_completed_query
    @course_completed_query ||= CourseCompletedQuery.new(@team.learning_partner_id, @duration)
  end

  def team_and_subteam_ids(team)
    return @team_and_subteam_ids unless @team_and_subteam_ids.empty?

    recursive_traverse_team_tree(team)
    @team_and_subteam_ids
  end

  def recursive_traverse_team_tree(team)
    @team_and_subteam_ids.push(team.id)
    team.sub_teams.includes(:sub_teams).each { |sub_team| recursive_traverse_team_tree(sub_team) } # rubocop:disable Rails/FindEach
  end

  def duration_cache_key
    "#{@duration.begin.to_i}-#{@duration.end.to_i}"
  end

  def base_cache_key
    version = Rails.cache.read("dashboard/team_#{@team.id}/version") || 1
    "dashboard/team_#{@team.id}/v#{version}/#{duration_cache_key}"
  end

  def filter_by_teams(events)
    team_ids = team_and_subteam_ids(@team)
    events.filter { |event| event.data['team_id'].nil? || team_ids.include?(event.data['team_id']) }
  end
end
