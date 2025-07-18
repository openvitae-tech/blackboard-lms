# frozen_string_literal: true

FactoryBot.define do
  factory :report do
    name { Faker::Lorem.words.join('_') }
    start_date { 1.month.ago }
    end_date { Time.zone.today }
    report_type { Report::TEAM_REPORT }
  end
end
