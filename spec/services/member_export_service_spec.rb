# frozen_string_literal: true

require 'rails_helper'
require 'zip'

RSpec.describe MemberExportService do
  subject(:service) { described_class.new(member, member_data, dashboard, team) }

  let(:team)    { create(:team) }
  let(:member)  { create(:user, :learner, t_team: team) }
  let(:duration) { 30.days.ago.beginning_of_day..Time.zone.now.end_of_day }
  let(:dashboard) { instance_double(Dashboard) }
  let(:member_data) do
    {
      engagement_series: {},
      courses_count: 3,
      courses_delta: 1,
      avg_completion_percent: 60,
      avg_completion_delta: 5,
      total_watch_seconds: 7200,
      watch_time_delta: 0,
      certificates_count: 1,
      certificates_delta: 0,
      quiz_pass_rate: 80,
      quizzes_passed: 4,
      total_quizzes: 5,
      self_assigned_count: 2
    }
  end

  before do
    allow(dashboard).to receive(:duration).and_return(duration)
  end

  describe '#generate' do
    it 'returns a non-empty binary string' do
      result = service.generate
      expect(result).to be_a(String).and be_present
    end

    it 'produces a valid xlsx (zip) file' do
      expect(service.generate.bytes.first(2)).to eq([0x50, 0x4B])
    end

    it 'generates five worksheets with the correct names' do
      expect(worksheet_names(service.generate)).to eq(
        ['Summary', 'Daily Engagement', 'Course Progress', 'Quiz Performance', 'Self-Assigned']
      )
    end

    it 'includes the member name in the summary sheet' do
      expect(sheet_xml(service.generate, 'xl/worksheets/sheet1.xml')).to include(member.display_name)
    end

    it 'includes quiz pass rate from member_data' do
      expect(sheet_xml(service.generate, 'xl/worksheets/sheet4.xml')).to include('80%')
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
