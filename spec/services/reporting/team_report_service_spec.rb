# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Reporting::TeamReportService do
  let(:team) { create(:team) }
  let(:user) { create(:user, :manager, team: team, learning_partner: team.learning_partner) }
  let(:report) { create(:report, team: team, generator: user) }
  let(:course) { create(:course, duration: 120) }

  before do
    create(:event, name: Event::COURSE_STARTED, user_id: user.id, data: { 'course_id' => course.id },
                   created_at: 2.weeks.ago, partner_id: team.learning_partner_id)
    create(:event, name: Event::COURSE_COMPLETED, user_id: user.id, data: { 'course_id' => course.id },
                   created_at: 1.day.ago, partner_id: team.learning_partner_id)
    create(:event, name: Event::LEARNING_TIME_SPENT, user_id: user.id,
                   data: { 'course_id' => course.id, 'time_spent' => 60 },
                   created_at: 1.week.ago,
                   partner_id: team.learning_partner_id)
  end

  describe '#generate' do
    it 'generates and attaches a CSV to the report' do
      service = described_class.new(report)
      service.generate

      expect(report.document).to be_attached
      content = report.document.download
      csv = CSV.parse(content, headers: true)
      expect(csv.headers).to match_array(described_class::REPORT_HEADERS)
      expect(csv.size).to be >= 1
    end
  end

  describe '#all_users' do
    it 'returns active users with matching role and team_id' do
      service = described_class.new(report)
      users = service.send(:all_users)
      expect(users).to include(user)
      expect(users.all? { |u| u.state == User::ACTIVE }).to be true
      expect(users.all? { |u| [User::LEARNER, User::MANAGER, User::OWNER].include?(u.role) }).to be true
    end
  end

  describe '#all_sub_teams' do
    it 'includes the given team and its subteams' do
      service = described_class.new(report)
      sub_team = create(:team, parent_team: team)
      all_teams = service.send(:all_sub_teams)
      expect(all_teams).to include(team, sub_team)
    end
  end

  describe '#course_completion_text' do
    let(:service) { described_class.new(report) }

    it 'returns correct completion percentage' do
      result = service.send(:course_completion_text, course, 60)
      expect(result).to eq('50.0%')
    end

    it 'returns NA for blank time' do
      result = service.send(:course_completion_text, course, nil)
      expect(result).to eq('NA')
    end
  end

  describe '#days' do
    let(:service) { described_class.new(report) }

    it 'returns number of days between doe and doc' do
      doe = 5.days.ago
      doc = Time.zone.today
      expect(service.send(:days, doe, doc)).to eq(5)
    end

    it 'returns NA if doe is blank' do
      expect(service.send(:days, nil, nil)).to eq('NA')
    end
  end

  describe '#role_text' do
    let(:service) { described_class.new(report) }

    it 'returns mapped user role text' do
      expect(service.send(:role_text, 'learner')).to eq(User::USER_ROLE_MAPPING[:learner])
    end
  end

  describe '#date_text' do
    let(:service) { described_class.new(report) }

    it 'returns formatted date' do
      date = Date.new(2023, 1, 15)
      expect(service.send(:date_text, date)).to eq('15/01/23')
    end

    it 'returns NA for nil date' do
      expect(service.send(:date_text, nil)).to eq('NA')
    end
  end

  describe '#time_spent_text' do
    let(:service) { described_class.new(report) }

    it 'returns time spent as string' do
      expect(service.send(:time_spent_text, 45)).to eq('45')
    end

    it 'returns NA for nil time' do
      expect(service.send(:time_spent_text, nil)).to eq('NA')
    end
  end
end
