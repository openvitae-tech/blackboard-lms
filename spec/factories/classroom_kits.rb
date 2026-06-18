# frozen_string_literal: true

FactoryBot.define do
  factory :classroom_kit do
    title { 'Test Classroom Kit' }
    sequence(:neo_ai_kit_id) { |n| "neo-kit-#{n}" }
    learning_partner { association :learning_partner }
  end

  factory :classroom_kit_component do
    classroom_kit { association :classroom_kit }
    sequence(:neo_ai_component_id) { |n| "neo-comp-#{n}" }
    component_type { 'slide_deck' }
    title { 'Slide deck for learners' }
  end
end
