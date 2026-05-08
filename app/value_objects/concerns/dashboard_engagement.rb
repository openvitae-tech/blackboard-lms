# frozen_string_literal: true

module DashboardEngagement
  def daily_hours_series
    series = build_empty_series
    fill_series_from_events(series)
    series
  end

  def total_hours
    (total_time_spent_metric / 3600.0).round(1)
  end

  def daily_avg_hours
    days = [(@duration.end.to_date - @duration.begin.to_date).to_i + 1, 1].max
    (total_hours / days).round(1)
  end

  def peak_day
    by_day = group_events_by_day
    return nil if by_day.empty?

    best_day_name(by_day)
  end

  def weekend_engagement_drop_percent
    by_day = group_events_by_day
    return 0 if by_day.empty?

    weekday_avg = weekday_seconds(by_day)
    weekend_avg = weekend_seconds(by_day)
    return 0 if weekday_avg.zero?

    [((weekday_avg - weekend_avg) / weekday_avg * 100).round, 0].max
  end

  def quizzes_passed
    @quizzes_passed ||= quiz_answers_in_period.where(status: 'correct').count
  end

  def total_quizzes
    @total_quizzes ||= quiz_answers_in_period.count
  end

  def quiz_pass_rate
    return 0 if total_quizzes.zero?

    (quizzes_passed.to_f / total_quizzes * 100).round
  end

  def assessments_passed
    @assessments_passed ||= completed_assessments_in_period.where(score: pass_score_threshold..).count
  end

  def total_assessments
    @total_assessments ||= completed_assessments_in_period.count
  end

  def assessment_pass_rate
    return 0 if total_assessments.zero?

    (assessments_passed.to_f / total_assessments * 100).round
  end

  private

  def current_time_spent_events
    @current_time_spent_events ||= Rails.cache.fetch("#{base_cache_key}/time_spent_events", expires_in: 5.minutes) do
      filter_by_teams(time_spent_query.call)
    end
  end

  def group_events_by_day
    current_time_spent_events.group_by { |e| e.created_at.to_date }
  end

  def build_empty_series
    (@duration.begin.to_date..@duration.end.to_date).each_with_object({}) { |d, h| h[date_key(d)] = 0 }
  end

  def fill_series_from_events(series)
    current_time_spent_events.group_by { |e| e.created_at.to_date }.each do |date, day_events|
      series[date_key(date)] = (day_events.map(&:data).sum { |v| v['time_spent'].to_i } / 3600.0).round(1)
    end
  end

  def best_day_name(by_day)
    by_day.max_by { |_, evts| evts.map(&:data).sum { |v| v['time_spent'].to_i } }.first.strftime('%A')
  end

  def weekday_seconds(by_day)
    daily_avg_seconds(by_day.reject { |d, _| d.saturday? || d.sunday? })
  end

  def weekend_seconds(by_day)
    daily_avg_seconds(by_day.select { |d, _| d.saturday? || d.sunday? })
  end

  def date_key(date)
    [date.day.to_s.rjust(2, '0'), Date::MONTHNAMES[date.month][0..2]].join(' ')
  end

  def daily_avg_seconds(day_hash)
    return 0.0 if day_hash.empty?

    total = day_hash.sum { |_, evts| evts.map(&:data).sum { |v| v['time_spent'].to_i } }
    total.to_f / day_hash.size
  end

  def quiz_answers_in_period
    QuizAnswer.joins(enrollment: :user)
              .where(users: { team_id: team_and_subteam_ids(@team) })
              .where(quiz_answers: { created_at: @duration })
  end

  def completed_assessments_in_period
    Assessment.joins(:user)
              .where(users: { team_id: team_and_subteam_ids(@team) })
              .where(status: Assessment::STATUS[:completed], completed_at: @duration)
  end

  def pass_score_threshold
    (Assessment::QUESTIONS_COUNT * Assessment::PASS_PERCENTAGE / 100.0).ceil
  end
end
