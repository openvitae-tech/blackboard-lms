# frozen_string_literal: true

FactoryBot.define do
  factory :program, class: 'Program' do
    name { Faker::Lorem.word }
    learning_partner
    courses { [] }
    users { [] }
  end
end
