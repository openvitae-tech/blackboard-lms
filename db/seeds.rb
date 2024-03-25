# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

about_text = "Nestled amidst breathtaking landscapes, Grand Hotel stands as an epitome of luxury and refinement. Renowned for its exquisite continental cuisine and impeccable service, this iconic establishment offers an unparalleled dining experience that captivates the senses. Each dish is meticulously crafted to perfection, showcasing the culinary mastery of our esteemed chefs. From the elegant ambiance to the attentive staff, every detail at Grand Hotel is designed to elevate your stay to unforgettable heights. Whether indulging in a sumptuous meal in our fine dining restaurant or savoring a decadent dessert in the charming cafe, guests are treated to a feast for both the palate and the soul. Experience the epitome of culinary excellence and unparalleled service at Grand Hotel, where every moment is a celebration of sophistication and taste."

if Rails.env.development?

  ActiveRecord::Base.transaction do
    root = User.create!(name: "Neo", role: "platform_admin", email: "root@example.com", password: "password", password_confirmation: "password")
    root.confirm

    partner = LearningPartner.create!(name: "The Grand Budapest Hotel", about: about_text)

    partner_admin = User.create!(name: "John Master", role: "platform_admin", email: "grand-admin@example.com", password: "password", password_confirmation: "password", learning_partner: partner)
    partner_admin.confirm

    learner = User.create!(name: "Jack Sparrow", role: "platform_admin", email: "grand-learner@example.com", password: "password", password_confirmation: "password", learning_partner: partner)
    learner.confirm
  end
end