FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password" }
    password_confirmation { "password" }
    confirmed_at { Time.now }

    trait :admin do
      role { "admin" }
    end

    trait :owner do
      role { "owner" }
    end

    trait :manager do
      role { "manager" }
    end

    trait :learner do
      role { "learner" }
    end
  end

  factory :learning_partner do
    name { Faker::Restaurant.name }
    about { Faker::Restaurant.description }
    logo { Rack::Test::UploadedFile.new("#{Rails.root}/spec/files/less_than_1_mb.jpg") }
    banner { Rack::Test::UploadedFile.new("#{Rails.root}/spec/files/less_than_1_mb.jpg") }
  end

  factory :quiz do
    question { Faker::Lorem.paragraph() }
    quiz_type { "MCQ" }
    option_a  { Faker::Lorem.word }
    option_b  { Faker::Lorem.word }
    option_c  { Faker::Lorem.word }
    option_d  { Faker::Lorem.word }
    answer { "c" }
  end

  factory :lesson do
    title { Faker::Lorem.word }
    description { Faker::Lorem.paragraph() }
    video_url { "https://example.com/948577869" }
    video_streaming_source { "example" }
    duration { 60 }
  end

  factory :course_module do
    title { Faker::Lorem.word }
    description { Faker::Lorem.paragraph() }
    seq_no { 1 }
  end

  factory :course do
    title { Faker::Movie.title }
    description { Faker::Lorem.paragraph() }

    trait :with_attachment do
      banner { Rack::Test::UploadedFile.new("#{Rails.root}/spec/files/less_than_1_mb.jpg") }
    end
  end
end


def course_with_associations(modules_count: 1, lessons_count: 1, quizzes_count: 1, duration: 60)
  FactoryBot.create(:course) do |course|
    module_seq_no = 1
    FactoryBot.create_list(:course_module, modules_count, course: course) do |course_module|
      course_module.update(seq_no: module_seq_no)
      module_seq_no += 1
      lesson_seq_no = 1
      FactoryBot.create_list(:lesson, lessons_count, course_module: course_module, duration: duration) do |lesson|
        lesson.update(seq_no: lesson_seq_no)
        lesson_seq_no += 1
      end

      quiz_seq_no = 1
      FactoryBot.create_list(:quiz, quizzes_count, course_module: course_module) do |quiz|
        quiz.update(seq_no: quiz_seq_no)
        quiz_seq_no += 1
      end
    end
  end
end