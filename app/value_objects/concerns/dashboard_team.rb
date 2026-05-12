# frozen_string_literal: true

# Handles team members, sub-teams, member profile metrics
module DashboardTeam
  def all_team_members_progress(page, query: nil)
    all = Rails.cache.fetch("#{base_cache_key}/team_members_progress/#{Digest::SHA1.hexdigest(query.to_s)}",
                            expires_in: 5.minutes) do
      users = User
              .where(team_id: team_and_subteam_ids(@team))
              .where(role: User::LEARNER)
              .active
              .includes(:enrollments, :team)
      users = users.where('name ILIKE ?', "%#{query}%") if query.present?

      users.map do |user|
        enrollments = user.enrollments.to_a
        total = enrollments.length
        completed = enrollments.count(&:course_completed)
        progress = calculate_progress(total, completed)
        { user:, courses: total, completed:, progress: }
      end
    end

    Kaminari.paginate_array(all, total_count: all.size).page(page).per(20)
  end

  def team_member_data(user)
    enrollments = user.enrollments.includes(course: :course_modules).to_a
    enrollment_stats(enrollments)
      .merge(user_quiz_stats(user))
      .merge(member_delta_stats(user, enrollments))
      .merge(member_engagement_data(user))
      .merge(
        self_assigned_enrollments: enrollments.select { |e| e.assigned_by_id.nil? && !e.course_completed }.first(3),
        course_enrollments: enrollments.sort_by { |e| -e.progress }.first(5)
      )
  end

  def team_member_status_counts
    all = Rails.cache.fetch("#{base_cache_key}/team_members_progress/", expires_in: 5.minutes) do
      User.where(team_id: team_and_subteam_ids(@team))
          .where(role: User::LEARNER)
          .active
          .includes(:enrollments)
          .map do |user|
            enrollments = user.enrollments.to_a
            total = enrollments.length
            completed = enrollments.count(&:course_completed)
            progress = calculate_progress(total, completed)
            { user:, courses: total, completed:, progress: }
          end
    end
    {
      completed: all.count { |m| m[:progress] == 100 },
      behind: all.count { |m| m[:progress] < 20 }
    }
  end

  def team_members_progress
    User
      .where(team_id: team_and_subteam_ids(@team))
      .where(role: User::LEARNER)
      .active
      .includes(:enrollments, :team)
      .limit(4)
      .map do |user|
        enrollments = user.enrollments.to_a
        total = enrollments.length
        completed = enrollments.count(&:course_completed)
        progress = calculate_progress(total, completed)
        { user:, courses: total, progress:, completed: }
      end
  end

  def sub_teams_progress
    sub_teams = @team.sub_teams # already preloaded via includes(sub_teams: :sub_teams)
    return [] if sub_teams.empty?

    sub_team_ids = sub_teams.map(&:id)

    total_by_team = Enrollment
                    .joins(:user)
                    .where(users: { team_id: sub_team_ids, role: User::LEARNER })
                    .merge(User.active)
                    .group('users.team_id')
                    .count

    completed_by_team = Enrollment
                        .joins(:user)
                        .where(users: { team_id: sub_team_ids, role: User::LEARNER },
                               course_completed: true)
                        .merge(User.active)
                        .group('users.team_id')
                        .count

    members_by_team = User
                      .where(team_id: sub_team_ids)
                      .active
                      .group(:team_id)
                      .count

    sub_teams.map do |sub_team|
      total = total_by_team.fetch(sub_team.id, 0)
      completed = completed_by_team.fetch(sub_team.id, 0)
      members_count = members_by_team.fetch(sub_team.id, 0)
      progress = calculate_progress(total, completed)
      { id: sub_team.id, name: sub_team.name, members_count:, progress: }
    end
  end

  private

  def enrollment_stats(enrollments)
    total = enrollments.size
    completed = enrollments.count(&:course_completed)
    avg_completion = calculate_progress(total, completed)
    {
      courses_count: total,
      completed_count: completed,
      avg_completion_percent: avg_completion,
      total_watch_seconds: enrollments.sum(&:time_spent)
    }
  end

  def user_quiz_stats(user)
    answers = QuizAnswer.joins(:enrollment)
                        .where(enrollments: { user_id: user.id })
                        .where(quiz_answers: { created_at: @duration })
    total = answers.count
    passed = answers.where(status: 'correct').count
    {
      quiz_pass_rate: total.zero? ? 0 : (passed.to_f / total * 100).round,
      quizzes_passed: passed,
      total_quizzes: total
    }
  end

  def member_delta_stats(user, enrollments)
    prev = previous_duration
    current_certs = CourseCertificate.where(user:, issued_at: @duration).count
    prev_certs = CourseCertificate.where(user:, issued_at: prev).count
    {
      certificates_count: current_certs,
      certificates_delta: current_certs - prev_certs,
      courses_delta: member_courses_delta(enrollments, prev),
      avg_completion_delta: member_completion_delta(enrollments, prev),
      self_assigned_count: member_self_assigned_count(enrollments),
      watch_time_delta: member_watch_time_delta(user)
    }
  end

  def member_courses_delta(enrollments, prev)
    enrollments.count { |e| @duration.cover?(e.created_at) } -
      enrollments.count { |e| prev.cover?(e.created_at) }
  end

  def member_completion_delta(enrollments, prev)
    total = enrollments.size
    return 0 if total.zero?

    current_pct = (enrollments.count do |e|
      e.course_completed && @duration.cover?(e.updated_at)
    end.to_f / total * 100).round
    prev_pct = (enrollments.count { |e| e.course_completed && prev.cover?(e.updated_at) }.to_f / total * 100).round
    current_pct - prev_pct
  end

  def member_self_assigned_count(enrollments)
    enrollments.count { |e| e.assigned_by_id.nil? && @duration.cover?(e.created_at) }
  end

  def member_watch_time_delta(user)
    current = current_time_spent_events.select { |e| e.user_id == user.id }
                                       .sum { |e| e.data['time_spent'].to_i }
    previous = TimeSpentQuery.new(@team.learning_partner_id, previous_duration).call
                             .select { |e| e.user_id == user.id }
                             .sum { |e| e.data['time_spent'].to_i }
    current - previous
  end

  def member_engagement_data(user)
    events = current_time_spent_events.select { |e| e.user_id == user.id }
    series = member_daily_series(events)
    total_hrs = member_total_hours(events)
    days = [(@duration.end.to_date - @duration.begin.to_date).to_i + 1, 1].max

    {
      engagement_series: series,
      total_watch_hours: total_hrs,
      daily_avg_watch_hours: (total_hrs / days).round(1),
      member_peak_day: member_peak_day(events)
    }
  end

  def member_daily_series(events)
    series = initialize_member_series
    fill_member_series(series, events)
    series
  end

  def member_total_hours(events)
    total_secs = events.sum { |e| e.data['time_spent'].to_i }
    (total_secs / 3600.0).round(1)
  end

  def member_peak_day(events)
    by_day = events.group_by { |e| e.created_at.to_date }
    return nil if by_day.empty?

    by_day.max_by { |_, d| d.sum { |e| e.data['time_spent'].to_i } }.first.strftime('%A')
  end

  def initialize_member_series
    (@duration.begin.to_date..@duration.end.to_date).each_with_object({}) { |d, h| h[date_key(d)] = 0 }
  end

  def fill_member_series(series, events)
    events.group_by { |e| e.created_at.to_date }.each do |date, day_events|
      series[date_key(date)] = (day_events.sum { |e| e.data['time_spent'].to_i } / 3600.0).round(1)
    end
  end

  def calculate_progress(total, completed)
    return 0 if total.nil? || total.zero?

    (completed.to_f / total * 100).round
  end
end
