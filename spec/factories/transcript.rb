# frozen_string_literal: true

FactoryBot.define do
  factory :transcript do
    association :local_content
    start_at { 1 }
    end_at { 2 }
    text { 'Sample transcript text' }
  end
end
