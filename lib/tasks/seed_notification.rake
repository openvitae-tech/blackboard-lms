# frozen_string_literal: true

namespace :testing do
  desc 'Seed notifications for a given user'
  task seed_notifications: :environment do
    raise 'It is not safe to run this in non development environment' unless Rails.env.development?

    email = ENV.fetch('email', nil)

    if email.blank?
      puts "Pass user email as argument eg: email='jubin@example.com'"
      exit(-1)
    end

    user = User.where(email:).first
    20.times.each do |_index|
      ntype = Notification::VALID_TYPES.sample
      link = [nil, '/supports'].sample
      NotificationService.notify(user, Faker::Lorem.sentence, Faker::Lorem.sentence, ntype:, link:)
    end
  end
end
