# frozen_string_literal: true

FactoryBot.define do
  factory :tag, class: 'Tag' do
    name { Faker::Alphanumeric.unique.alpha(number: 10) }
    tag_type { 'category' }

    trait :level do
      name { Faker::Alphanumeric.unique.alpha(number: 5) }
      tag_type { 'level' }
    end
  end
end
