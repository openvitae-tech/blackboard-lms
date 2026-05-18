# frozen_string_literal: true

require 'caxlsx'

class DashboardExportService
  include Exports::SpreadsheetHelpers

  MAX_ROWS = 1000

  def initialize(dashboard, team, duration)
    @dashboard = dashboard
    @team      = team
    @duration  = duration
  end

  def generate
    package = Axlsx::Package.new
    wbk = package.workbook

    header_style    = wbk.styles.add_style(bg_color: HEADER_COLOR, fg_color: HEADER_FG, b: true, sz: 11)
    highlight_style = wbk.styles.add_style(bg_color: WIDEST_GAP_COLOR)

    add_summary_sheet(wbk, header_style)
    add_engagement_sheet(wbk, header_style)
    add_started_vs_completed_sheet(wbk, header_style, highlight_style)
    add_recent_activity_sheet(wbk, header_style)
    add_team_members_sheet(wbk, header_style)
    add_sub_teams_sheet(wbk, header_style)
    add_self_assigned_sheet(wbk, header_style)

    package.to_stream.read
  end

  private

  # ─── Sheet 1: Summary ────────────────────────────────────────────────────

  def add_summary_sheet(wbk, header_style)
    wbk.add_worksheet(name: 'Summary') do |sheet|
      sheet.add_row ['Dashboard Export Report'], b: true, sz: 14
      sheet.add_row ['Team', @team.name]
      sheet.add_row ['Period', duration_label(@dashboard.duration)]
      sheet.add_row ['Generated at', Time.zone.now.strftime('%d %b %Y %H:%M')]
      sheet.add_row []
      sheet.add_row ['Metric', 'Value', 'Change vs Previous Period'], style: header_style
      summary_metric_rows.each { |row| sheet.add_row row }
      sheet.column_widths 35, 25, 30
    end
  end

  # ─── Sheet 2: Daily Engagement ───────────────────────────────────────────

  def add_engagement_sheet(wbk, header_style)
    series = @dashboard.time_spent_series

    wbk.add_worksheet(name: 'Daily Engagement') do |sheet|
      sheet.add_row ['Date', 'Minutes Spent'], style: header_style

      series.each do |date_key, minutes|
        sheet.add_row [date_key, minutes]
      end

      peak_date = series.max_by { |_, v| v }
      if peak_date
        sheet.add_row []
        sheet.add_row ['Peak Day', peak_date[0], "#{peak_date[1]} minutes"]
      end

      sheet.column_widths 20, 20
    end
  end

  # ─── Sheet 3: Started vs Completed ───────────────────────────────────────

  def add_started_vs_completed_sheet(wbk, header_style, highlight_style)
    widest_gap  = @dashboard.widest_gap_courses
    widest_ids  = widest_gap.to_set { |item| item[:course].id }
    all_courses = @dashboard.all_started_vs_completed(1, exclude_ids: []).per(MAX_ROWS)

    wbk.add_worksheet(name: 'Started vs Completed') do |sheet|
      sheet.add_row ['* Highlighted rows have the widest gap between started and completed'], i: true
      sheet.add_row ['Course', 'Total Enrollments', 'Started (period)',
                     'Completed (period)', 'Started %', 'Completed %',
                     'Last Activity', 'Widest Gap?'], style: header_style

      all_courses.each do |item|
        is_gap = widest_ids.include?(item[:course].id)
        row_options = is_gap ? { style: highlight_style } : {}
        sheet.add_row [
          item[:course].title,
          item[:total],
          item[:started],
          item[:completed],
          "#{item[:started_percent]}%",
          "#{item[:completed_percent]}%",
          item[:last_activity_at]&.strftime('%d %b %Y') || '—',
          is_gap ? 'Yes' : 'No'
        ], **row_options
      end

      sheet.column_widths 40, 20, 20, 20, 14, 14, 20, 14
    end
  end

  # ─── Sheet 4: Recent Activity ─────────────────────────────────────────────

  def add_recent_activity_sheet(wbk, header_style)
    activities = @dashboard.all_recent_activity(1).per(MAX_ROWS)

    wbk.add_worksheet(name: 'Recent Activity') do |sheet|
      sheet.add_row %w[Date User Team Activity Course], style: header_style
      activities.each { |item| sheet.add_row activity_row(item) }
      sheet.column_widths 22, 28, 28, 20, 40
    end
  end

  # ─── Sheet 5: Team Members ────────────────────────────────────────────────

  def add_team_members_sheet(wbk, header_style)
    members = @dashboard.all_team_members_progress(1).per(MAX_ROWS)

    wbk.add_worksheet(name: 'Team Members') do |sheet|
      sheet.add_row ['Name', 'Team', 'Courses Assigned', 'Completed', 'Progress %'], style: header_style

      members.each do |item|
        sheet.add_row [
          item[:user].display_name,
          item[:team_name] || '—',
          item[:courses],
          item[:completed],
          "#{item[:progress]}%"
        ]
      end

      sheet.column_widths 30, 28, 20, 15, 15
    end
  end

  # ─── Sheet 6: Sub-teams ───────────────────────────────────────────────────

  def add_sub_teams_sheet(wbk, header_style)
    sub_teams = @dashboard.sub_teams_progress

    wbk.add_worksheet(name: 'Sub-teams') do |sheet|
      if sub_teams.empty?
        sheet.add_row ['No sub-teams found for this team.']
      else
        sheet.add_row ['Sub-team', 'Members', 'Progress %'], style: header_style

        sub_teams.each do |item|
          sheet.add_row [item[:name], item[:members_count], "#{item[:progress]}%"]
        end

        sheet.column_widths 30, 15, 15
      end
    end
  end

  # ─── Sheet 7: Self-Assigned Courses ──────────────────────────────────────

  def add_self_assigned_sheet(wbk, header_style)
    team_ids    = @team.team_hierarchy_ids
    enrollments = Enrollment
                  .joins(:user, :course)
                  .where(users: { team_id: team_ids })
                  .where(assigned_by_id: nil)
                  .includes(course: :course_modules)
                  .order(created_at: :desc)
                  .first(MAX_ROWS)

    users_by_id = User.includes(:team)
                      .where(id: enrollments.map(&:user_id).uniq)
                      .index_by(&:id)

    wbk.add_worksheet(name: 'Self-Assigned') do |sheet|
      if enrollments.empty?
        sheet.add_row ['No self-assigned courses found for this team.']
      else
        sheet.add_row ['Learner', 'Team', 'Course', 'Progress %', 'Completed', 'Enrolled On'],
                      style: header_style
        enrollments.each { |e| sheet.add_row self_assigned_row(e, users_by_id) }
        sheet.column_widths 30, 25, 45, 14, 14, 18
      end
    end
  end

  def summary_metric_rows
    [
      ['Active Learners', @dashboard.active_learners_count, delta_label(@dashboard.active_learners_delta)],
      ['Completion %', "#{@dashboard.completion_percent_metric}%", delta_label(@dashboard.completion_percent_delta)],
      ['Avg Time Spent', format_seconds(@dashboard.average_time_spent_metric),
       delta_label(@dashboard.average_time_spent_delta)],
      ['Certificates Earned', @dashboard.certificates_count, delta_label(@dashboard.certificates_delta)],
      ['Active Courses', @dashboard.active_course_count_metric, '—'],
      ['Learners Falling Behind', @dashboard.falling_behind_count, '—']
    ]
  end

  def activity_row(item)
    [
      item[:created_at].strftime('%d %b %Y %H:%M'),
      item[:user]&.display_name || '—',
      item[:user]&.team&.name || '—',
      item[:action_text].capitalize,
      item[:resource_name] || '—'
    ]
  end

  def self_assigned_row(enrollment, users_by_id)
    user = users_by_id[enrollment.user_id]
    [
      user&.display_name || '—',
      user&.team&.name || '—',
      enrollment.course.title,
      "#{enrollment.progress}%",
      enrollment.course_completed ? 'Yes' : 'No',
      enrollment.created_at.strftime('%d %b %Y')
    ]
  end
end
