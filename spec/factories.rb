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
end