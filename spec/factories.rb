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

    trait :admin do
      role { 'admin' }
    end

    trait :owner do
      role { 'owner' }
    end

    trait :manager do
      role { 'manager' }
    end

    trait :learner do
      role { 'learner' }
    end
  end

  factory :learning_partner do
    name { Faker::Restaurant.name }
    content { Faker::Restaurant.description }
    logo { Rack::Test::UploadedFile.new(Rails.root.join('spec/files/less_than_1_mb.jpg').to_s) }
    banner { Rack::Test::UploadedFile.new(Rails.root.join('spec/files/less_than_1_mb.jpg').to_s) }
  end

  factory :team do
    name { Faker::Team.name }
    banner { Rack::Test::UploadedFile.new(Rails.root.join('spec/files/less_than_1_mb.jpg').to_s) }

    association :learning_partner, factory: :learning_partner
  end

  factory :quiz do
    question { Faker::Lorem.paragraph }
    quiz_type { 'MCQ' }
    option_a  { Faker::Lorem.word }
    option_b  { Faker::Lorem.word }
    option_c  { Faker::Lorem.word }
    option_d  { Faker::Lorem.word }
    answer { 'c' }
  end

  factory :lesson do
    title { Faker::Lorem.word }
    rich_description { Faker::Lorem.paragraph }
    video_url { 'https://example.com/948577869' }
    video_streaming_source { 'example' }
    duration { 60 }
  end

  factory :course_module do
    title { Faker::Lorem.word }
    rich_description { Faker::Lorem.paragraph }
  end

  factory :course do
    title { Faker::Lorem.sentence(word_count: 6) }
    description { Faker::Lorem.paragraph_by_chars(number: 140) }

    trait :with_attachment do
      banner { Rack::Test::UploadedFile.new(Rails.root.join('spec/files/less_than_1_mb.jpg').to_s) }
    end
  end
end

def course_with_associations(modules_count: 1, lessons_count: 1, quizzes_count: 1, duration: 60)
  FactoryBot.create(:course) do |course|
    module_ids = []
    FactoryBot.create_list(:course_module, modules_count, course:) do |course_module|
      lesson_ids = []
      FactoryBot.create_list(:lesson, lessons_count, course_module:, duration:) do |lesson|
        lesson_ids.push(lesson.id)
      end

      quiz_ids = []
      FactoryBot.create_list(:quiz, quizzes_count, course_module:) do |quiz|
        quiz_ids.push(quiz.id)
      end
      course_module.lessons_in_order = lesson_ids
      course_module.quizzes_in_order = quiz_ids
      course_module.save!
      module_ids.push(course_module.id)
    end
    course.course_modules_in_order = module_ids
    course.save!
  end
end
