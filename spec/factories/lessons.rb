# frozen_string_literal: true

FactoryBot.define do
  factory :lesson do
    title { Faker::Lorem.word }
    rich_description { Faker::Lorem.paragraph }
    video_streaming_source { 'example' }
    duration { 60 }
    course_module

    after(:build) do |lesson|
      lesson.local_contents << build(:local_content, lesson:)
    end
  end
end
