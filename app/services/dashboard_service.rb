# frozen_string_literal: true

class DashboardService
  include Singleton

  class Dashboard

    attr_reader :team, :duration

    def initialize(team, duration)
      @team = team
      @duration =
        case duration
        when "last_7_days" then 7.days.ago.beginning_of_day..Time.zone.today.beginning_of_day
        when "last_14_days" then 14.days.ago.beginning_of_day..Time.zone.today.beginning_of_day
        when "last_30_days" then 30.days.ago.beginning_of_day..Time.zone.today.beginning_of_day
        when "last_month" then 2.months.ago.beginning_of_month..2.months.ago.end_of_month
        else
          7.days.ago.beginning_of_day..Time.zone.today.beginning_of_day
        end
    end

    def time_spent_series
      events = time_spent_query.call
      data = {}
      grouped_data = events.group_by { |event| to_grouping_key(event) }

      grouped_data.each do |key, values|
        data[key] = values.map(&:data).map { |v| v[:time_spent].to_i }.reduce(&:+) || 0
      end

      data
    end

    def total_time_spent_metric
      events = time_spent_query.call
      events.map(&:data).map { |v| v[:time_spent].to_i }.reduce(&:+) || 0
    end

    def average_time_spent_metric
      total_time_spent_metric / @team.users.count
    end

    def active_course_count_metric
      events = time_spent_query.call
      events.map(&:data).map { |v| v[:course_id] }.uniq.count || 0
    end

    def team_score_metric
      # TODO: need better implementation
      @team.score
    end

    def total_course_time_metric
      events = time_spent_query.call
      course_ids = events.map(&:data).map { |v| v[:course_id] }.uniq
      Course.includes(:course_modules).where(id: course_ids).map(&:duration).sum
    end

    def completion_percent_metric
      return 0 if total_course_time_metric < 1
      (total_time_spent_metric / total_course_time_metric.to_f * 100).round
    end

    def lesson_views_series
      events = lesson_viewed_query.call
      data = {}
      grouped_data = events.group_by { |event| to_grouping_key(event) }

      grouped_data.each do |key, values|
        data[key] = values.count
      end

      data
    end

    def course_enrolled_series
      events = user_enrolled_query.call
      data = {}
      grouped_data = events.group_by { |event| to_grouping_key(event) }

      grouped_data.each do |key, values|
        data[key] = values.count
      end

      data
    end

    private

    def to_grouping_key(event)
      [event.created_at.day.to_s.rjust(2, "0"), Date::MONTHNAMES[event.created_at.month][0..2]].join(' ')
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
  end

  def build_dashboard_for(team, duration)
    Dashboard.new(team, duration)
  end
end