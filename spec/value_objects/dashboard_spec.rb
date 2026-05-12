# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard do
  let(:learning_partner) { create(:learning_partner) }
  let(:team) { create(:team, learning_partner:) }
  let(:learner) { create(:user, :learner, t_team: team) }
  let(:course) { create(:course) }
  let(:dashboard) { described_class.new(team, 'last_7_days') }

  before do
    Rails.cache.clear
    # Stub TimeSpentQuery so tests that call team_member_data or
    # current_time_spent_events don't need Event records
    allow_any_instance_of(TimeSpentQuery).to receive(:call).and_return([])
  end

  # ---------------------------------------------------------------------------
  # base_cache_key
  # ---------------------------------------------------------------------------
  describe '#base_cache_key' do
    it 'includes the team id' do
      expect(dashboard.send(:base_cache_key)).to include("team_#{team.id}")
    end

    it 'includes unix timestamps for duration start and end' do
      duration = dashboard.instance_variable_get(:@duration)
      key = dashboard.send(:base_cache_key)
      expect(key).to include(duration.begin.to_i.to_s)
      expect(key).to include(duration.end.to_i.to_s)
    end

    context 'with a custom date Range' do
      let(:from) { 10.days.ago.beginning_of_day }
      let(:to)   { 3.days.ago.end_of_day }
      let(:dashboard) { described_class.new(team, from..to) }

      it 'reflects the custom range as unix timestamps' do
        key = dashboard.send(:base_cache_key)
        expect(key).to include(from.to_i.to_s)
        expect(key).to include(to.to_i.to_s)
      end

      it 'produces different keys for same-day ranges with different times' do
        dashboard_a = described_class.new(team, from.all_day)
        dashboard_b = described_class.new(team, from.noon..from.end_of_day)
        expect(dashboard_a.send(:base_cache_key)).not_to eq(dashboard_b.send(:base_cache_key))
      end
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — completions_count
  # ---------------------------------------------------------------------------
  describe '#completions_count' do
    it 'counts enrollments completed within the duration' do
      travel_to(3.days.ago) { Enrollment.create!(user: learner, course:, course_completed: true) }
      expect(dashboard.completions_count).to eq(1)
    end

    it 'excludes completions updated outside the duration' do
      travel_to(30.days.ago) { Enrollment.create!(user: learner, course:, course_completed: true) }
      expect(dashboard.completions_count).to eq(0)
    end

    it 'excludes non-completed enrollments' do
      Enrollment.create!(user: learner, course:, course_completed: false)
      expect(dashboard.completions_count).to eq(0)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — new_starts_count
  # ---------------------------------------------------------------------------
  describe '#new_starts_count' do
    it 'counts enrollments started within the duration' do
      Enrollment.create!(user: learner, course:, course_started_at: 2.days.ago)
      expect(dashboard.new_starts_count).to eq(1)
    end

    it 'excludes starts outside the duration' do
      Enrollment.create!(user: learner, course:, course_started_at: 30.days.ago)
      expect(dashboard.new_starts_count).to eq(0)
    end

    it 'excludes enrollments that have not been started' do
      Enrollment.create!(user: learner, course:, course_started_at: nil)
      expect(dashboard.new_starts_count).to eq(0)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — upcoming_deadlines
  # ---------------------------------------------------------------------------
  describe '#upcoming_deadlines' do
    it 'returns enrollments with deadline within the next 5 days' do
      Enrollment.create!(user: learner, course:, deadline_at: 3.days.from_now, course_completed: false)
      result = dashboard.upcoming_deadlines
      expect(result.size).to eq(1)
      expect(result.first[:course]).to eq(course)
    end

    it 'includes incomplete_count and days_left in each result' do
      Enrollment.create!(user: learner, course:, deadline_at: 2.days.from_now, course_completed: false)
      result = dashboard.upcoming_deadlines.first
      expect(result[:incomplete_count]).to eq(1)
      expect(result[:days_left]).to eq(2)
    end

    it 'excludes completed enrollments' do
      Enrollment.create!(user: learner, course:, deadline_at: 2.days.from_now, course_completed: true)
      expect(dashboard.upcoming_deadlines).to be_empty
    end

    it 'excludes deadlines beyond 5 days' do
      Enrollment.create!(user: learner, course:, deadline_at: 10.days.from_now, course_completed: false)
      expect(dashboard.upcoming_deadlines).to be_empty
    end

    it 'excludes enrollments with no deadline' do
      Enrollment.create!(user: learner, course:, deadline_at: nil, course_completed: false)
      expect(dashboard.upcoming_deadlines).to be_empty
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — course_enrollment_data (via started_vs_completed)
  # ---------------------------------------------------------------------------
  describe '#course_enrollment_data (via started_vs_completed)' do
    it 'counts completed only when updated_at falls within the duration' do
      travel_to(2.days.ago) { Enrollment.create!(user: learner, course:, course_completed: true) }
      result = dashboard.started_vs_completed.find { |r| r[:course] == course }
      expect(result[:completed]).to eq(1)
    end

    it 'does not count completed enrollment updated outside the duration' do
      travel_to(30.days.ago) { Enrollment.create!(user: learner, course:, course_completed: true) }
      result = dashboard.started_vs_completed.find { |r| r[:course] == course }
      expect(result[:completed]).to eq(0)
    end

    it 'counts started as started-but-not-completed enrollments' do
      Enrollment.create!(user: learner, course:, course_started_at: 2.days.ago, course_completed: false)
      result = dashboard.started_vs_completed.find { |r| r[:course] == course }
      expect(result[:started]).to eq(1)
    end

    it 'does not count a completed enrollment in the started bucket' do
      travel_to(2.days.ago) do
        Enrollment.create!(user: learner, course:, course_started_at: Time.current, course_completed: true)
      end
      result = dashboard.started_vs_completed.find { |r| r[:course] == course }
      expect(result[:started]).to eq(0)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — started_vs_completed
  # ---------------------------------------------------------------------------
  describe '#started_vs_completed' do
    let(:another_learner) { create(:user, :learner, t_team: team) }

    it 'returns at most 3 items' do
      4.times { Enrollment.create!(user: learner, course: create(:course), course_started_at: 1.day.ago) }
      expect(dashboard.started_vs_completed.size).to be <= 3
    end

    it 'orders by most recent activity first' do
      course_old = create(:course)
      course_new = create(:course)
      Enrollment.create!(user: learner, course: course_old, course_started_at: 5.days.ago)
      Enrollment.create!(user: another_learner, course: course_new, course_started_at: 1.day.ago)
      result = dashboard.started_vs_completed
      expect(result.first[:course]).to eq(course_new)
    end

    it 'includes total, completed, started, and percentage fields' do
      Enrollment.create!(user: learner, course:, course_started_at: 1.day.ago, course_completed: false)
      result = dashboard.started_vs_completed.find { |r| r[:course] == course }
      expect(result.keys).to include(:total, :completed, :started, :completed_percent, :started_percent,
                                     :last_activity_at)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — widest_gap_courses
  # ---------------------------------------------------------------------------
  describe '#widest_gap_courses' do
    let(:second_learner) { create(:user, :learner, t_team: team) }
    let(:third_learner)  { create(:user, :learner, t_team: team) }

    it 'returns courses where some enrollments are not yet completed' do
      Enrollment.create!(user: learner, course:, course_completed: false, course_started_at: 1.day.ago)
      expect(dashboard.widest_gap_courses.map { |r| r[:course] }).to include(course)
    end

    it 'excludes courses where all enrollments are completed within the duration' do
      travel_to(2.days.ago) { Enrollment.create!(user: learner, course:, course_completed: true) }
      expect(dashboard.widest_gap_courses).to be_empty
    end

    it 'returns at most 3 items' do
      4.times do
        Enrollment.create!(user: learner, course: create(:course), course_completed: false,
                           course_started_at: 1.day.ago)
      end
      expect(dashboard.widest_gap_courses.size).to be <= 3
    end

    it 'orders by largest gap (total minus completed) first' do
      course_small_gap = create(:course)
      course_big_gap   = create(:course)

      Enrollment.create!(user: learner, course: course_small_gap, course_completed: false, course_started_at: 1.day.ago)

      Enrollment.create!(user: second_learner, course: course_big_gap, course_completed: false,
                         course_started_at: 1.day.ago)
      Enrollment.create!(user: third_learner, course: course_big_gap, course_completed: false,
                         course_started_at: 1.day.ago)

      result = dashboard.widest_gap_courses
      expect(result.first[:course]).to eq(course_big_gap)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — all_started_vs_completed
  # ---------------------------------------------------------------------------
  describe '#all_started_vs_completed' do
    it 'returns paginated results (20 per page)' do
      21.times { Enrollment.create!(user: learner, course: create(:course), course_started_at: 1.day.ago) }
      result = dashboard.all_started_vs_completed(1)
      expect(result.size).to eq(20)
    end

    it 'filters by query term (case-insensitive title match)' do
      matching_course = create(:course, title: 'Ruby on Rails Fundamentals')
      other_course    = create(:course, title: 'Python Basics')
      Enrollment.create!(user: learner, course: matching_course, course_started_at: 1.day.ago)
      Enrollment.create!(user: learner, course: other_course,    course_started_at: 1.day.ago)
      result = dashboard.all_started_vs_completed(1, query: 'ruby')
      expect(result.map { |r| r[:course] }).to include(matching_course)
      expect(result.map { |r| r[:course] }).not_to include(other_course)
    end

    it 'excludes specified course ids' do
      Enrollment.create!(user: learner, course:, course_started_at: 1.day.ago)
      result = dashboard.all_started_vs_completed(1, exclude_ids: [course.id])
      expect(result.map { |r| r[:course] }).not_to include(course)
    end

    it 'returns all courses when no filters are applied' do
      Enrollment.create!(user: learner, course:, course_started_at: 1.day.ago)
      result = dashboard.all_started_vs_completed(1)
      expect(result.map { |r| r[:course] }).to include(course)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — recent_activities
  # ---------------------------------------------------------------------------
  describe '#recent_activities' do
    it 'returns at most 3 items' do
      allow(dashboard).to receive_messages(certificate_activities: Array.new(4) {
        { type: 'certificate', created_at: rand(1..5).days.ago }
      }, event_activities: [])
      expect(dashboard.recent_activities.size).to be <= 3
    end

    it 'orders by most recent created_at first' do
      older = { type: 'certificate', created_at: 5.days.ago }
      newer = { type: 'certificate', created_at: 1.day.ago }
      allow(dashboard).to receive_messages(certificate_activities: [older, newer], event_activities: [])
      activities = dashboard.recent_activities
      expect(activities.first[:created_at]).to be > activities.last[:created_at]
    end

    it 'combines event and certificate activities' do
      event_activity = { type: 'started', created_at: 2.days.ago }
      cert_activity  = { type: 'certificate', created_at: 1.day.ago }
      allow(dashboard).to receive_messages(event_activities: [event_activity], certificate_activities: [cert_activity])
      types = dashboard.recent_activities.map { |a| a[:type] }
      expect(types).to include('started', 'certificate')
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardActivity — all_recent_activity
  # ---------------------------------------------------------------------------
  describe '#all_recent_activity' do
    it 'returns a paginated result (20 per page)' do
      activities = Array.new(21) { { type: 'certificate', created_at: rand(1..5).days.ago } }
      allow(dashboard).to receive_messages(all_certificate_activities: activities, all_event_activities: [])
      result = dashboard.all_recent_activity(1)
      expect(result.size).to eq(20)
    end

    it 'returns second page correctly' do
      activities = Array.new(21) { { type: 'certificate', created_at: rand(1..5).days.ago } }
      allow(dashboard).to receive_messages(all_certificate_activities: activities, all_event_activities: [])
      result = dashboard.all_recent_activity(2)
      expect(result.size).to eq(1)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardTeam — team_members_progress
  # ---------------------------------------------------------------------------
  describe '#team_members_progress' do
    it 'returns at most 4 members' do
      5.times { create(:user, :learner, t_team: team) }
      expect(dashboard.team_members_progress.size).to be <= 4
    end

    it 'calculates progress percentage as completed / total * 100' do
      Enrollment.create!(user: learner, course:, course_completed: true)
      course2 = create(:course)
      Enrollment.create!(user: learner, course: course2, course_completed: false)
      result = dashboard.team_members_progress.find { |m| m[:user] == learner }
      expect(result[:progress]).to eq(50)
      expect(result[:courses]).to eq(2)
      expect(result[:completed]).to eq(1)
    end

    it 'returns 0 progress for learners with no enrollments' do
      user = learner # force DB creation before the query runs
      result = dashboard.team_members_progress.find { |m| m[:user] == user }
      expect(result[:progress]).to eq(0)
    end

    it 'only includes active learners on the team' do
      inactive = create(:user, :learner, t_team: team, state: 'in-active')
      result = dashboard.team_members_progress
      expect(result.map { |m| m[:user] }).not_to include(inactive)
    end

    it 'does not include managers' do
      manager = create(:user, :manager, t_team: team)
      result = dashboard.team_members_progress
      expect(result.map { |m| m[:user] }).not_to include(manager)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardTeam — all_team_members_progress
  # ---------------------------------------------------------------------------
  describe '#all_team_members_progress' do
    it 'returns paginated results (20 per page)' do
      21.times { create(:user, :learner, t_team: team) }
      result = dashboard.all_team_members_progress(1)
      expect(result.size).to eq(20)
    end

    it 'returns the second page' do
      21.times { create(:user, :learner, t_team: team) }
      result = dashboard.all_team_members_progress(2)
      expect(result.size).to eq(1)
    end

    it 'filters by name query' do
      matching = create(:user, :learner, t_team: team, name: 'Alice Wonderland')
      other    = create(:user, :learner, t_team: team, name: 'Bob Smith')
      result   = dashboard.all_team_members_progress(1, query: 'Alice')
      expect(result.map { |m| m[:user] }).to include(matching)
      expect(result.map { |m| m[:user] }).not_to include(other)
    end
  end

  # ---------------------------------------------------------------------------
  # DashboardTeam — team_member_data
  # ---------------------------------------------------------------------------
  describe '#team_member_data' do
    it 'returns all expected keys' do
      result = dashboard.team_member_data(learner)
      expect(result.keys).to include(
        :courses_count, :completed_count, :avg_completion_percent, :total_watch_seconds,
        :quiz_pass_rate, :quizzes_passed, :total_quizzes,
        :certificates_count, :certificates_delta, :courses_delta,
        :avg_completion_delta, :self_assigned_count, :watch_time_delta,
        :self_assigned_enrollments, :course_enrollments
      )
    end

    it 'counts total enrollments as courses_count' do
      Enrollment.create!(user: learner, course:)
      expect(dashboard.team_member_data(learner)[:courses_count]).to eq(1)
    end

    it 'calculates avg_completion_percent correctly' do
      Enrollment.create!(user: learner, course:, course_completed: true)
      Enrollment.create!(user: learner, course: create(:course), course_completed: false)
      expect(dashboard.team_member_data(learner)[:avg_completion_percent]).to eq(50)
    end

    it 'limits self_assigned_enrollments to 3 incomplete self-assigned' do
      4.times do
        Enrollment.create!(user: learner, course: create(:course), assigned_by_id: nil, course_completed: false)
      end
      expect(dashboard.team_member_data(learner)[:self_assigned_enrollments].size).to be <= 3
    end

    it 'limits course_enrollments to 5' do
      6.times { Enrollment.create!(user: learner, course: create(:course)) }
      expect(dashboard.team_member_data(learner)[:course_enrollments].size).to be <= 5
    end

    it 'counts courses_delta as enrollments created in the current period minus previous period' do
      Enrollment.create!(user: learner, course:) # created now (within last_7_days)
      expect(dashboard.team_member_data(learner)[:courses_delta]).to eq(1)
    end

    it 'counts self_assigned_count for self-assigned enrollments created within the duration' do
      Enrollment.create!(user: learner, course:, assigned_by_id: nil)
      expect(dashboard.team_member_data(learner)[:self_assigned_count]).to eq(1)
    end

    it 'excludes manager-assigned enrollments from self_assigned_count' do
      manager = create(:user, :manager, t_team: team)
      Enrollment.create!(user: learner, course:, assigned_by_id: manager.id)
      expect(dashboard.team_member_data(learner)[:self_assigned_count]).to eq(0)
    end

    it 'calculates avg_completion_delta as current period completion % minus previous period %' do
      travel_to(3.days.ago) { Enrollment.create!(user: learner, course:, course_completed: true) }
      result = dashboard.team_member_data(learner)
      # 1 completed / 1 total = 100% current, 0% previous → delta = 100
      expect(result[:avg_completion_delta]).to eq(100)
    end

    it 'returns current-period count for certificates_count' do
      create(:course_certificate, user: learner, course:, issued_at: 3.days.ago)
      expect(dashboard.team_member_data(learner)[:certificates_count]).to eq(1)
    end

    it 'returns positive delta when more certs earned this period than previous' do
      create(:course_certificate, user: learner, course:, issued_at: 3.days.ago)
      result = dashboard.team_member_data(learner)
      # 1 this period, 0 previous → delta = 1
      expect(result[:certificates_delta]).to eq(1)
    end

    it 'returns negative delta when fewer certs earned this period than previous' do
      create(:course_certificate, user: learner, course:, issued_at: 10.days.ago)
      result = dashboard.team_member_data(learner)
      # 0 this period, 1 previous → delta = -1
      expect(result[:certificates_delta]).to eq(-1)
    end
  end

  # ---------------------------------------------------------------------------
  # Caching behaviour
  # ---------------------------------------------------------------------------
  describe 'caching' do
    it 'returns cached result on second call without hitting the DB' do
      Rails.cache.clear
      first_result = dashboard.recent_activities

      # Mutate DB after first fetch — enrollment added should not appear
      create(:enrollment, user: learner, course:)

      second_result = dashboard.recent_activities
      expect(second_result).to eq(first_result)
    end

    it 'returns fresh data after enrollment commit invalidates the cache version' do
      Rails.cache.clear
      first_result = dashboard.recent_activities

      # Trigger cache invalidation via after_commit callback
      enrollment = create(:enrollment, user: learner, course:)
      enrollment.update!(updated_at: Time.current)

      fresh_dashboard = described_class.new(team, 'last_7_days')
      second_result = fresh_dashboard.recent_activities
      expect(second_result).not_to eq(first_result)
    end
  end
end
