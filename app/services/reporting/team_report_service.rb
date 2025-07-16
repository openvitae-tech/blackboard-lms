# frozen_string_literal: true

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

    REPORT_HEADERS = FIELDS.map { |name| Kernel.const_get(name.upcase) }.freeze
    ReportDate = Data.define(*FIELDS.map(&:downcase).map(&:to_sym))

    attr_reader :report

    def initialize(report)
      @report = report
      @sub_teams = []
      @all_users = []
    end

    def generate
      @team = @report.team
      user_ids = all_users.map(&:id)
      partner_id = @team.learning_partner_id
      events = TeamReportQuery.new(partner_id, nil, user_ids).run_query
      rows = process_events(events)
      write_csv_and_attach_to_report(rows)
    end

    private

    def write_csv_and_attach_to_report(rows); end

    def process_events(events)
      user_data = {}

      events.each do |event|
        user_info = user_data.fetch(event.user_id, {})

        user_info[:user] = all_users.find { |user| user.id == event.user_id } if user_info[:user].blank?

        user = user_info[:user]

        user_info[NAME] = user.name
        user_info[]
      end

      user_data.map do |_user_id, data|
        ReportDate.new(**data)
      end
    end

    def all_users
      return @all_users unless @all_users.empty?

      @all_users = User.where(
        id: all_sub_teams.map(&:id),
        role: [User::MANAGER, User::LEARNER, User::OWNER],
        state: [User::ACTIVE]
      )
    end

    def all_sub_teams
      return @sub_teams unless @sub_teams.empty?

      sub_teams(@team)
    end

    def sub_teams(team)
      @sub_teams.append(team)
      team.sub_teams.each do |sub_team|
        sub_teams(sub_team)
      end
    end
  end
end
