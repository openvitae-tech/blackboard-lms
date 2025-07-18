# frozen_string_literal: true

require 'csv'

module Reporting
  class TeamReportService
    NAME = 'Name'
    COURSE = 'Course'
    COMPLETION = '% of completion'
    DOE = 'Date of enrollment'
    DOC = 'Date of completion'
    DAYS = 'Days spent'
    ROLE = 'User role'
    TEAM_NAME = 'Team'
    MINUTES = 'Time spent (min)'

    FIELDS = %w[NAME COURSE COMPLETION DOE DOC DAYS ROLE TEAM_NAME MINUTES].freeze

    REPORT_HEADERS = FIELDS.map { |name| const_get(name.upcase) }.freeze
    ReportDate = Data.define(*FIELDS.map(&:downcase).map(&:to_sym)) do
      def to_row
        [name, course, completion, doe, doc, days, role, team_name, minutes]
      end
    end
    CourseData = Data.define(:doe, :doc, :time_spent)

    attr_reader :report

    def initialize(report)
      @report = report
      @all_sub_teams = []
      @all_users = []
      @team = @report.team
    end

    def generate
      user_ids = all_users.map(&:id)
      partner_id = @team.learning_partner_id
      events = TeamReportQuery.new(partner_id, nil, user_ids).call
      rows = process_events(events)
      write_csv_and_attach_to_report(rows)
    end

    private

    def write_csv_and_attach_to_report(rows)
      csv_data = CSV.generate(headers: true) do |csv|
        csv << REPORT_HEADERS
        rows.each do |row|
          csv << row
        end
      end

      @report.document.attach(io: StringIO.new(csv_data), filename: "#{@report.name}.csv", content_type: 'text/csv')
    end

    def process_events(events)
      users_data = build_user_data
      users_data = aggregate_event_data(events, users_data)
      course_ids = users_data.map { |_user_id, data| data[:courses].keys }.flatten.uniq
      load_courses(course_ids)
      build_rows(users_data)
    end

    def build_user_data
      users_data = {}

      all_users.each do |user|
        user_record = all_users.find { |u| u.id == user.id }
        user_info = {}
        user_info[:name] = user_record.name
        user_info[:role] = user_record.role
        user_info[:team_name] = all_sub_teams.find { |team| team.id == user.team_id }&.name
        user_info[:courses] = {}
        users_data[user.id] = user_info
      end

      users_data
    end

    def aggregate_event_data(events, users_data)
      events.each do |event|
        user_info = users_data.fetch(event.user_id, {})
        data = event.data
        course_data = user_info[:courses][data['course_id']]

        case event.name
        when Event::COURSE_STARTED
          updated_course_data = CourseData.new(
            doe: event.created_at,
            doc: course_data&.doc,
            time_spent: course_data&.time_spent
          )
          user_info[:courses][data['course_id']] = updated_course_data
        when Event::COURSE_COMPLETED
          updated_course_data = CourseData.new(
            doe: course_data&.doe,
            doc: event.created_at,
            time_spent: course_data&.time_spent
          )
          user_info[:courses][data['course_id']] = updated_course_data
        when Event::LEARNING_TIME_SPENT
          updated_course_data = CourseData.new(
            doe: course_data&.doe,
            doc: course_data&.doc,
            time_spent: data['time_spent'] + course_data&.time_spent.to_i
          )
          user_info[:courses][data['course_id']] = updated_course_data
        end
        users_data[event.user_id] = user_info
      end

      users_data
    end

    def build_rows(users_data)
      rows = []
      users_data.each_value do |data|
        data[:courses].each do |course_id, course_data|
          course = courses.find { |c| c.id == course_id }

          report_row = ReportDate.new(
            name: data[:name],
            course: course_text(course),
            completion: course_completion_text(course, course_data.time_spent),
            doe: date_text(course_data.doe),
            doc: date_text(course_data.doc),
            days: days(course_data.doe, course_data.doc).to_s,
            role: role_text(data[:role]),
            team_name: data[:team_name],
            minutes: time_spent_text(course_data.time_spent)
          )

          rows << report_row.to_row
        end
      end

      rows
    end

    def all_users
      return @all_users unless @all_users.empty?

      @all_users = User.where(
        team_id: all_sub_teams.map(&:id),
        role: [User::MANAGER, User::LEARNER, User::OWNER],
        state: User::ACTIVE
      )
    end

    def all_sub_teams
      return @all_sub_teams unless @all_sub_teams.empty?

      sub_teams(@team)
      @all_sub_teams
    end

    attr_reader :courses

    def load_courses(ids)
      @courses = Course.where(id: ids)
    end

    def sub_teams(team)
      @all_sub_teams.append(team)

      team.sub_teams.each do |sub_team|
        sub_teams(sub_team)
      end
    end

    def days(doe, doc)
      return 'NA' if doe.blank?

      doc = Time.zone.today if doc.blank?
      (doc.to_date - doe.to_date).to_i
    end

    def role_text(role)
      User::USER_ROLE_MAPPING[role.to_sym]
    end

    def time_spent_text(time_spent)
      return 'NA' if time_spent.blank?

      time_spent.to_s
    end

    def course_completion_text(course, time_spent)
      return 'NA' if course.blank? || time_spent.blank? || course.duration.zero?

      percentage = (time_spent / course.duration.to_f * 100).round(2)
      "#{percentage}%"
    end

    def course_text(course)
      return 'NA' if course.blank?

      course.title
    end

    def date_text(date)
      return 'NA' if date.blank?

      date.to_date.strftime('%d/%m/%y')
    end
  end
end
