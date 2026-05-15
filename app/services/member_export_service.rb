# frozen_string_literal: true

require 'caxlsx'

class MemberExportService
  HEADER_COLOR = '1F3A5F'
  HEADER_FG    = 'FFFFFF'

  def initialize(member, member_data, dashboard, team)
    @member      = member
    @data        = member_data
    @dashboard   = dashboard
    @team        = team
  end

  def generate
    package = Axlsx::Package.new
    wbk = package.workbook
    header_style = wbk.styles.add_style(bg_color: HEADER_COLOR, fg_color: HEADER_FG, b: true, sz: 11)

    add_summary_sheet(wbk, header_style)
    add_engagement_sheet(wbk, header_style)
    add_course_progress_sheet(wbk, header_style)
    add_quiz_sheet(wbk, header_style)
    add_self_assigned_sheet(wbk, header_style)

    package.to_stream.read
  end

  private

  def duration_label
    range = @dashboard.duration
    "#{range.begin.strftime('%d %b %Y')} – #{range.end.strftime('%d %b %Y')}"
  end

  def delta_label(value)
    return 'No change' if value.to_i.zero?

    value.to_i.positive? ? "+#{value}" : value.to_s
  end

  def format_seconds(seconds)
    return '0m' if seconds.to_i.zero?

    hours   = seconds / 3600
    minutes = (seconds % 3600) / 60
    hours.positive? ? "#{hours}h #{minutes}m" : "#{minutes}m"
  end

  # ─── Sheet 1: Summary ────────────────────────────────────────────────────

  def add_summary_sheet(wbk, header_style)
    wbk.add_worksheet(name: 'Summary') do |sheet|
      sheet.add_row ['Member Export Report'], b: true, sz: 14
      sheet.add_row ['Name',        @member.display_name]
      sheet.add_row ['Team',        @member.team&.name || '—']
      sheet.add_row ['Last Active', @member.last_sign_in_at&.strftime('%d %b %Y %H:%M') || '—']
      sheet.add_row ['Period',      duration_label]
      sheet.add_row ['Generated at', Time.zone.now.strftime('%d %b %Y %H:%M')]
      sheet.add_row []
      sheet.add_row ['Metric', 'Value', 'Change vs Previous Period'], style: header_style
      summary_metric_rows.each { |row| sheet.add_row row }
      sheet.column_widths 35, 25, 30
    end
  end

  # ─── Sheet 2: Daily Engagement ───────────────────────────────────────────

  def add_engagement_sheet(wbk, header_style)
    series = @data[:engagement_series] || {}

    wbk.add_worksheet(name: 'Daily Engagement') do |sheet|
      sheet.add_row ['Date', 'Hours Watched'], style: header_style

      series.each do |date_key, hours|
        sheet.add_row [date_key, hours]
      end

      peak = series.max_by { |_, v| v }
      if peak
        sheet.add_row []
        sheet.add_row ['Peak Day', peak[0], "#{peak[1]} hrs"]
      end

      sheet.column_widths 22, 20
    end
  end

  # ─── Sheet 3: Course Progress ─────────────────────────────────────────────

  def add_course_progress_sheet(wbk, header_style)
    enrollments = Enrollment.includes(:course)
                            .where(user: @member)
                            .order(created_at: :desc)

    wbk.add_worksheet(name: 'Course Progress') do |sheet|
      sheet.add_row ['Course', 'Progress %', 'Completed', 'Enrolled On'], style: header_style
      enrollments.each { |e| sheet.add_row course_progress_row(e) }
      sheet.column_widths 45, 14, 14, 18
    end
  end

  # ─── Sheet 4: Quiz Performance ────────────────────────────────────────────

  def add_quiz_sheet(wbk, header_style)
    wbk.add_worksheet(name: 'Quiz Performance') do |sheet|
      sheet.add_row %w[Metric Value], style: header_style
      sheet.add_row ['Quizzes Passed', @data[:quizzes_passed]]
      sheet.add_row ['Total Quizzes',  @data[:total_quizzes]]
      sheet.add_row ['Pass Rate',      "#{@data[:quiz_pass_rate]}%"]

      sheet.column_widths 30, 20
    end
  end

  # ─── Sheet 5: Self-Assigned Courses ──────────────────────────────────────

  def add_self_assigned_sheet(wbk, header_style)
    enrollments = Enrollment.includes(:course)
                            .where(user: @member, assigned_by_id: nil)
                            .order(created_at: :desc)

    wbk.add_worksheet(name: 'Self-Assigned') do |sheet|
      sheet.add_row ['Course', 'Progress %', 'Completed', 'Enrolled On'], style: header_style

      if enrollments.any?
        enrollments.each { |e| sheet.add_row course_progress_row(e) }
      else
        sheet.add_row ['No self-assigned courses found.']
      end

      sheet.column_widths 45, 14, 14, 18
    end
  end

  def summary_metric_rows
    [
      ['Courses Enrolled',      @data[:courses_count], delta_label(@data[:courses_delta])],
      ['Avg Completion %',      "#{@data[:avg_completion_percent]}%", delta_label(@data[:avg_completion_delta])],
      ['Total Watch Time',      format_seconds(@data[:total_watch_seconds].to_i),
       delta_label(@data[:watch_time_delta])],
      ['Certificates Earned',   @data[:certificates_count].to_i, delta_label(@data[:certificates_delta])],
      ['Quiz Pass Rate',        "#{@data[:quiz_pass_rate]}%", '—'],
      ['Quizzes Passed',        "#{@data[:quizzes_passed]}/#{@data[:total_quizzes]}", '—'],
      ['Self-Assigned Courses', @data[:self_assigned_count].to_i, '—']
    ]
  end

  def course_progress_row(enrollment)
    [
      enrollment.course.title,
      "#{enrollment.progress}%",
      enrollment.course_completed ? 'Yes' : 'No',
      enrollment.created_at.strftime('%d %b %Y')
    ]
  end
end
