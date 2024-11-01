# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

require_relative '../spec/support/helpers'

class DevelopmentSeed
  include Singleton
  include Helpers

  def seed
    ActiveRecord::Base.transaction do
      admins = [%w[Deepak admin]]

      admins.each { |name, role| create_user(name, role) }

      other_users = [
        %w[Jubin owner],
        %w[Ajith manager],
        %w[Poornima learner]
      ]

      partners = [
        ['The Grand Budapest Hotel', about_text, 'hotel_logo.jpg', 'hotel_banner.jpg'],
        [Faker::Restaurant.name, about_text, 'hotel_logo.jpg', 'hotel_banner.jpg']
      ]

      partners.each { |name, about, logo, banner| create_partner(name, about, logo, banner) }

      partner = LearningPartner.first
      team = Team.where(learning_partner_id: partner.id).first

      other_users.each { |name, role| create_user(name, role, partner, team) }

      courses = [['F & B Fundamentals',
                  "Discover the art and science of food and beverages with our comprehensive course. Designed for aspiring chefs, hospitality professionals, and food enthusiasts, this program covers essential culinary techniques, advanced cooking methods, and beverage pairing principles. Learn from industry experts through hands-on practice and interactive lessons. Explore global cuisines, master presentation skills, and understand the business aspects of the food and beverage industry. Enhance your knowledge of food safety, nutrition, and sustainable practices. Whether you're starting a new career or refining your skills, this course provides the tools and knowledge needed to excel. Join us and embark on a flavorful journey that blends passion with professionalism.", 'course_banner.jpeg']]

      courses.each { |title, description, banner| create_course(title, description, banner) }

      course = Course.first

      modules = [['Body Language', "Welcome to your next lesson on body language. The key to unlocking genuine warmth and hospitality with our guests lies in mastering positive body language. It's about the silent messages we send through our gestures, facial expressions, and posture."],
                 ['Etiquette & Manners',
                  "Welcome to your new lesson on Etiquette and Manners. Etiquette and manners are the silent ambassadors of our hotel's reputation. They speak volumes about our dedication to excellence, ensuring every guest feels welcomed and respected."],
                 ['Grooming And Hygiene',
                  'Elevate your personal and professional image with our Grooming and Hygiene course. Designed for individuals seeking to enhance their appearance and health, this program covers essential grooming techniques, skincare routines, and hygiene practices.'],
                 ['Guest Complaints',
                  "In this session, we're going to delve deep into the strategies that ensure every guest leaves our establishment not just satisfied, but feeling genuinely valued and cared for."]]

      module_ids = modules.map { |title, description| create_module(title, description, course) }.map(&:id)
      course.course_modules_in_order = module_ids
      course.save!

      course_module = course.first_module

      lessons1 = [
        ['Overview', 'It is the unspoken communication between human beings', 'https://vimeo.com/948577869'],
        ['Gestures', 'Right gestures nails it all', 'https://vimeo.com/948577869'],
        ['Zone Distance', 'Each person has his own personal territory', 'https://vimeo.com/948577869'],
        ["Do's and Dont's", "What you should do and what shouldn't", 'https://vimeo.com/948577869']
      ]

      lesson_ids1 = lessons1.map do |title, description, url|
        create_lesson(title, description, url, course_module)
      end.map(&:id)
      course_module.lessons_in_order = lesson_ids1
      course_module.save!

      lessons2 = [
        ['Handling Guest Complaints', 'Order placed incorrectly and wrong orders reaching at a table..', 'https://vimeo.com/948577869'],
        ['Service Recovery', 'A waiter explaining something to a group of guests at a table in a busy restaurant.', 'https://vimeo.com/948577869']
      ]
      course_module = course_module.next_module
      lesson_ids2 = lessons2.map do |title, description, url|
        create_lesson(title, description, url, course_module)
      end.map(&:id)
      course_module.lessons_in_order = lesson_ids2
      course_module.save!

      quizzes = [
        ['What does crossing your arms typically signify in body language?', 'Openness', 'Defensiveness', 'Happiness',
         'Interest', 'B'],
        ['Which of the following body language cues often indicates that a person is nervous or anxious?',
         'Leaning forward', 'Making direct eye contact', 'Fidgeting with objects', 'Smiling broadly', 'C'],
        ['When someone mirrors your body language, it generally means they are', 'Distracted', 'Disinterested',
         'Opposing you', 'Building rapport', 'D'],
        ['Standing with hands on hips is generally seen as a gesture of:', 'Submission', 'Dominance or confidence',
         'Confusion', 'Relaxation', 'B']
      ]

      quizzes_ids = quizzes.map do |question, a, b, c, d, ans|
        create_quiz(question, a, b, c, d, ans, course_module)
      end.map(&:id)
      course_module.quizzes_in_order = quizzes_ids
      course_module.save!
    end
  end

  private

  def create_user(name, role, partner = nil, team = nil)
    ActiveRecord::Base.transaction do
      user = User.create!(
        name:,
        role:,
        email: "#{name.downcase}@example.com",
        password: 'password',
        password_confirmation: 'password',
        learning_partner: partner,
        team:
      )

      user.confirm
    end
  end

  def create_partner(name, about, logo, banner)
    partner = LearningPartner.create!(
      name:,
      content: about,
      logo: File.open(Rails.root.join("db/data/#{logo}")),
      banner: File.open(Rails.root.join("db/data/#{banner}"))
    )

    Team.create!(name: "Default Team", banner: File.open(Rails.root.join("db/data/#{banner}")), learning_partner_id: partner.id)
  end

  def create_course(name, description, banner)
    Course.create!(
      title: name,
      description:,
      banner: File.open(Rails.root.join("db/data/#{banner}")),
      is_published: true
    )
  end

  def create_module(name, description, course)
    m = CourseModule.new(
      title: name,
      rich_description: description,
      course:
    )

    m.save!
    m
  end

  def create_lesson(title, description, url, course_module)
    l = Lesson.new(title:, rich_description: description, video_url: url, duration: rand(1..10),
                   course_module:)
    CourseManagementService.instance.set_lesson_attributes(course_module, l)
    l.save!
    l
  end

  def create_quiz(q, a, b, c, d, ans, course_module)
    q = Quiz.new(question: q, option_a: a, option_b: b, option_c: c, option_d: d, answer: ans,
                 course_module:)
    q.save!
    q
  end
end

DevelopmentSeed.instance.seed if Rails.env.development?
