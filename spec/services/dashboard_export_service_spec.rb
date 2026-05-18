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
      binary = service.generate
      Zip::File.open_buffer(binary) do |zip|
        xml = zip.find_entry('xl/worksheets/sheet1.xml').get_input_stream.read
        expect(xml).to include(team.name)
      end
    end

    it 'includes the formatted period in the summary sheet' do
      binary   = service.generate
      expected = duration.begin.strftime('%d %b %Y')
      Zip::File.open_buffer(binary) do |zip|
        shared_strings = zip.find_entry('xl/sharedStrings.xml').get_input_stream.read
        expect(shared_strings).to include(expected)
      end
    end
  end

  def worksheet_names(xlsx_binary)
    Zip::File.open_buffer(xlsx_binary) do |zip|
      content = zip.find_entry('xl/workbook.xml').get_input_stream.read
      content.scan(/<sheet\b[^>]+name="([^"]+)"/).flatten
    end
  end
end
