# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password' }
    password_confirmation { 'password' }
    confirmed_at { Time.zone.now }
    # numbers starting with 11 will be considered as test numbers
    phone { "11#{Faker::Number.number(digits: 8)}" }
    state { 'active' }

    transient do
      t_team { create :team }
    end

    trait :admin do
      role { 'admin' }
    end

    trait :owner do
      role { 'owner' }
      learning_partner { t_team.learning_partner }
      team { t_team }
    end

    trait :manager do
      role { 'manager' }
      learning_partner { t_team.learning_partner }
      team { t_team }
    end

    trait :learner do
      role { 'learner' }
      learning_partner { t_team.learning_partner }
      team { t_team }
    end
  end
end
