# frozen_string_literal: true

FactoryBot.define do
  factory :event do
    name { 'Sample event' }
    user_id { Faker::Number.digit }
    partner_id { Faker::Number.digit }
  end
end
