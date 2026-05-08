# frozen_string_literal: true

module DashboardActivity
  def recent_activities
    team_user_ids = User.where(team_id: team_and_subteam_ids(@team)).pluck(:id)
    (event_activities(team_user_ids) + certificate_activities(team_user_ids))
      .sort_by { |a| a[:created_at] }
      .reverse
      .first(3)
  end

  def all_recent_activity(page)
    all = Rails.cache.fetch("#{base_cache_key}/recent_activity", expires_in: 5.minutes) do
      team_user_ids = User.where(team_id: team_and_subteam_ids(@team)).pluck(:id)
      (all_event_activities(team_user_ids) + all_certificate_activities(team_user_ids))
        .sort_by { |a| a[:created_at] }
        .reverse
    end
    Kaminari.paginate_array(all, total_count: all.size).page(page).per(20)
  end

  def completions_count
    Enrollment
      .joins(:user)
      .where(users: { team_id: team_and_subteam_ids(@team) })
      .where(course_completed: true)
      .where(updated_at: @duration)
      .count
  end

  def new_starts_count
    Enrollment
      .joins(:user)
      .where(users: { team_id: team_and_subteam_ids(@team) })
      .where.not(course_started_at: nil)
      .where(course_started_at: @duration)
      .count
  end

  def started_vs_completed
    course_enrollment_data
      .sort_by { |item| item[:last_activity_at] || Time.zone.at(0) }
      .reverse
      .first(3)
  end

  def widest_gap_courses
    course_enrollment_data
      .select { |item| (item[:total] - item[:completed]).positive? }
      .sort_by { |item| -(item[:total] - item[:completed]) }
      .first(3)
  end

  def all_started_vs_completed(page, exclude_ids: [], query: nil)
    all = course_enrollment_data.reject { |item| exclude_ids.include?(item[:course].id) }
    all = all.select { |item| item[:course].title.downcase.include?(query.downcase) } if query.present?
    all = all.sort_by { |item| item[:last_activity_at] || Time.zone.at(0) }.reverse
    Kaminari.paginate_array(all, total_count: all.size).page(page).per(20)
  end

  def upcoming_deadlines
    Enrollment
      .joins(:user, :course)
      .where(users: { team_id: team_and_subteam_ids(@team) })
      .where(course_completed: false)
      .where(deadline_at: Time.current.beginning_of_day..5.days.from_now.end_of_day)
      .includes(:user, :course)
      .order(:deadline_at)
      .group_by(&:course)
      .map do |course, enrollments|
        {
          course:,
          deadline_at: enrollments.first.deadline_at,
          incomplete_count: enrollments.count,
          days_left: (enrollments.first.deadline_at.to_date - Date.current).to_i
        }
      end
  end

  def overdue_deadlines
    Enrollment
      .joins(:user, :course)
      .where(users: { team_id: team_and_subteam_ids(@team) })
      .where(course_completed: false)
      .where('deadline_at IS NOT NULL AND deadline_at < ?', Time.current.beginning_of_day)
      .includes(:user, :course)
      .order(:deadline_at)
      .group_by(&:course)
      .map do |course, enrollments|
        {
          course:,
          deadline_at: enrollments.first.deadline_at,
          incomplete_count: enrollments.count,
          days_overdue: (Date.current - enrollments.first.deadline_at.to_date).to_i
        }
      end
  end

  def self_assigned_enrollments
    Enrollment
      .joins(:user, :course)
      .where(users: { team_id: team_and_subteam_ids(@team) })
      .where(assigned_by_id: nil, course_completed: false)
      .includes(:user, course: :course_modules)
      .order(created_at: :desc)
      .limit(3)
  end

  private

  def course_enrollment_data
    @course_enrollment_data ||= Rails.cache.fetch("#{base_cache_key}/course_enrollment_data", expires_in: 5.minutes) do
      Enrollment
        .joins(:user, :course)
        .where(users: { team_id: team_and_subteam_ids(@team) })
        .includes(:course)
        .group_by(&:course)
        .map { |course, ces| enrollment_row(course, ces) }
    end
  end

  def enrollment_row(course, course_enrollments)
    total     = course_enrollments.count
    completed = course_enrollments.count { |e| e.course_completed && @duration.cover?(e.updated_at) }
    started   = course_enrollments.count do |e|
      e.course_started_at.present? && !e.course_completed && @duration.cover?(e.course_started_at)
    end
    {
      course:, total:, completed:, started:,
      last_activity_at: last_activity_for(course_enrollments),
      completed_percent: safe_percent(completed, total),
      started_percent: safe_percent(started, total)
    }
  end

  def last_activity_for(course_enrollments)
    course_enrollments.filter_map do |e|
      [e.course_started_at, e.course_completed ? e.updated_at : nil].compact.max
    end.max
  end

  def safe_percent(count, total)
    total.zero? ? 0 : (count.to_f / total * 100).round
  end

  def event_activities(team_user_ids)
    events = Event
             .where(partner_id: @team.learning_partner_id)
             .where(name: [Event::COURSE_COMPLETED, Event::COURSE_STARTED])
             .where(user_id: team_user_ids)
             .where(created_at: @duration)
             .order(created_at: :desc)
             .limit(10)
             .to_a
    map_events_to_activities(events)
  end

  def certificate_activities(team_user_ids)
    CourseCertificate
      .joins(:user)
      .where(users: { id: team_user_ids })
      .where(issued_at: @duration)
      .includes(:user, :course)
      .order(issued_at: :desc)
      .limit(5)
      .map { |cert| certificate_activity_hash(cert) }
  end

  def all_event_activities(team_user_ids)
    events = Event
             .where(partner_id: @team.learning_partner_id)
             .where(name: [Event::COURSE_COMPLETED, Event::COURSE_STARTED])
             .where(user_id: team_user_ids)
             .where(created_at: @duration)
             .order(created_at: :desc)
             .to_a
    map_events_to_activities(events)
  end

  def all_certificate_activities(team_user_ids)
    CourseCertificate
      .joins(:user)
      .where(users: { id: team_user_ids })
      .where(issued_at: @duration)
      .includes(:user, :course)
      .order(issued_at: :desc)
      .map { |cert| certificate_activity_hash(cert) }
  end

  def map_events_to_activities(events)
    users = User.where(id: events.map(&:user_id).uniq).index_by(&:id)
    courses = Course.where(id: events.map { |e| e.data['course_id'] }.compact.uniq).index_by(&:id)
    events.map { |event| event_activity_hash(event, users, courses) }
  end

  def event_activity_hash(event, users, courses)
    type = event.name == Event::COURSE_COMPLETED ? 'completed' : 'started'
    {
      type:,
      action_text: type,
      resource_name: courses[event.data['course_id']]&.title,
      user: users[event.user_id],
      created_at: event.created_at
    }
  end

  def certificate_activity_hash(cert)
    {
      type: 'certificate',
      action_text: 'earned a certificate in',
      resource_name: cert.course.title,
      user: cert.user,
      created_at: cert.issued_at
    }
  end
end
