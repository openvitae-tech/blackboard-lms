# frozen_string_literal: true

module DashboardTeam
  def all_team_members_progress(page, query: nil)
    all = Rails.cache.fetch("#{base_cache_key}/team_members_progress/#{query}", expires_in: 5.minutes) do
      users = User
              .where(team_id: team_and_subteam_ids(@team))
              .where(role: User::LEARNER)
              .active
              .includes(:enrollments, :team)
      users = users.where('name ILIKE ?', "%#{query}%") if query.present?

      users.map do |user|
        total = user.enrollments.size
        completed = user.enrollments.count(&:course_completed)
        progress = total.zero? ? 0 : (completed.to_f / total * 100).round
        { user:, courses: total, completed:, progress: }
      end
    end

    Kaminari.paginate_array(all, total_count: all.size).page(page).per(20)
  end

  def team_member_data(user)
    enrollments = user.enrollments.includes(:course).to_a
    enrollment_stats(enrollments)
      .merge(user_quiz_stats(user))
      .merge(member_delta_stats(user, enrollments))
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
            total = user.enrollments.size
            completed = user.enrollments.count(&:course_completed)
            progress = total.zero? ? 0 : (completed.to_f / total * 100).round
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
      .includes(:enrollments)
      .limit(4)
      .map do |user|
        total = user.enrollments.size
        completed = user.enrollments.count(&:course_completed)
        progress = total.zero? ? 0 : (completed.to_f / total * 100).round
        { user:, courses: total, progress:, completed: }
      end
  end

  def sub_teams_progress
    @team.sub_teams.map do |sub_team|
      total = Enrollment.joins(:user).where(users: { team_id: sub_team.id }).count
      completed = Enrollment.joins(:user).where(users: { team_id: sub_team.id }, course_completed: true).count
      members_count = User.where(team_id: sub_team.id).active.count
      progress = total.zero? ? 0 : (completed.to_f / total * 100).round
      { name: sub_team.name, members_count:, progress: }
    end
  end

  private

  def enrollment_stats(enrollments)
    total = enrollments.size
    completed = enrollments.count(&:course_completed)
    avg_completion = total.zero? ? 0 : (completed.to_f / total * 100).round
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
end
