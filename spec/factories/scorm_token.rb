# frozen_string_literal: true

FactoryBot.define do
  factory :scorm_token, class: 'ScormToken' do
    learning_partner
  end
end
