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

      modules = ['Body Language',
                 'Etiquette & Manners',
                 'Grooming And Hygiene',
                 'Guest Complaints']

      module_ids = modules.map { |title| create_module(title, course) }.map(&:id)
      course.course_modules_in_order = module_ids
      course.save!

      course_module = course.first_module

      lessons1 = [
        ['Overview', 'It is the unspoken communication between human beings'],
        ['Gestures', 'Right gestures nails it all'],
        ['Zone Distance', 'Each person has his own personal territory'],
        ["Do's and Dont's", "What you should do and what shouldn't"]
      ]

      lesson_ids1 = lessons1.map do |title, description|
        lesson = create_lesson(title, description, course_module)
        create_local_content(lesson)
      end.map(&:id)
      course_module.lessons_in_order = lesson_ids1
      course_module.save!

      lessons2 = [
        ['Handling Guest Complaints', 'Order placed incorrectly and wrong orders reaching at a table..'],
        ['Service Recovery', 'A waiter explaining something to a group of guests at a table in a busy restaurant.']
      ]
      course_module = course_module.next_module
      lesson_ids2 = lessons2.map do |title, description|
       lesson = create_lesson(title, description, course_module)
       create_local_content(lesson)
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

  def create_module(name, course)
    CourseModule.reset_column_information
    m = CourseModule.create!(
      title: name,
      course:
    )
    m
  end

  def create_lesson(title, description, course_module)
    Lesson.reset_column_information
    l = Lesson.new(title:, rich_description: description, duration: rand(1..10),
                   course_module:)
    CourseManagementService.instance.set_lesson_attributes(course_module, l)
    l.save!
    l
  end

  def create_local_content(lesson)
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample_video.mp4')),
      filename: 'sample_video.mp4',
      content_type: 'video/mp4'
    )
    lesson.local_contents.create!(lang: "english", blob_id: blob.id)
  end

  def create_quiz(q, a, b, c, d, ans, course_module)
    q = Quiz.new(question: q, option_a: a, option_b: b, option_c: c, option_d: d, answer: ans,
                 course_module:)
    q.save!
    q
  end
end

DevelopmentSeed.instance.seed if Rails.env.development?
