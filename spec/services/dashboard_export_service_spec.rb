# frozen_string_literal: true

require 'rails_helper'
require 'zip'

RSpec.describe DashboardExportService do
  subject(:service) { described_class.new(dashboard, team, duration) }

  let(:team)     { create(:team) }
  let(:duration) { 30.days.ago.beginning_of_day..Time.zone.now.end_of_day }
  let(:dashboard) { instance_double(Dashboard) }
  let(:empty_page) { Enrollment.none.page(1) }

  before do
    allow(dashboard).to receive_messages(
      duration: duration,
      time_spent_series: {},
      widest_gap_courses: [],
      all_started_vs_completed: empty_page,
      all_recent_activity: empty_page,
      all_team_members_progress: empty_page,
      sub_teams_progress: [],
      active_learners_count: 10,
      active_learners_delta: 2,
      completion_percent_metric: 75,
      completion_percent_delta: -5,
      average_time_spent_metric: 3600,
      average_time_spent_delta: 0,
      certificates_count: 3,
      certificates_delta: 1,
      active_course_count_metric: 5,
      falling_behind_count: 2
    )
  end

  describe '#generate' do
    it 'returns a non-empty binary string' do
      result = service.generate
      expect(result).to be_a(String).and be_present
    end

    it 'produces a valid xlsx (zip) file' do
      expect(service.generate.bytes.first(2)).to eq([0x50, 0x4B])
    end

    it 'generates seven worksheets with the correct names' do
      expect(worksheet_names(service.generate)).to eq(
        ['Summary', 'Daily Engagement', 'Started vs Completed',
         'Recent Activity', 'Team Members', 'Sub-teams', 'Self-Assigned']
      )
    end

    it 'includes the team name in the summary sheet' do
      expect(sheet_xml(service.generate, 'xl/worksheets/sheet1.xml')).to include(team.name)
    end

    it 'includes the formatted period in the summary sheet' do
      expected = duration.begin.strftime('%d %b %Y')
      expect(sheet_xml(service.generate, 'xl/worksheets/sheet1.xml')).to include(expected)
    end
  end

  def worksheet_names(xlsx_binary)
    Zip::InputStream.open(StringIO.new(xlsx_binary)) do |zip|
      while (entry = zip.get_next_entry)
        next unless entry.name == 'xl/workbook.xml'

        return zip.read.scan(/<sheet\b[^>]+name="([^"]+)"/).flatten
      end
    end
    []
  end

  def sheet_xml(xlsx_binary, entry_name)
    Zip::InputStream.open(StringIO.new(xlsx_binary)) do |zip|
      while (entry = zip.get_next_entry)
        return zip.read if entry.name == entry_name
      end
    end
    ''
  end
end
