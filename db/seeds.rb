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
        ['The Grand Budapest Hotel', about_text],
        [Faker::Restaurant.name, about_text]
      ]

      partners.each { |name, about| create_partner(name, about) }

      partner = LearningPartner.first
      team = Team.where(learning_partner_id: partner.id).first

      other_users.each { |name, role| create_user(name, role, partner, team) }

      (0..10).each do
        setup_course
      end
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

  def create_partner(name, about)
    partner = LearningPartner.create!(
      name:,
      content: about,
      logo: File.open(Rails.root.join("app/assets/images/#{STATIC_ASSETS[:hotel_logo]}")),
      banner: File.open(Rails.root.join("app/assets/images/#{STATIC_ASSETS[:team_banner]}"))
    )

    Team.create!(name: "Default Team", banner: File.open(Rails.root.join("app/assets/images/#{STATIC_ASSETS[:team_banner]}")), learning_partner_id: partner.id)
  end

  def setup_course
    course = create_course
    course_modules = Array.new(rand(1..10)).map do |name|
      setup_course_module(course)
    end
    course.update!(course_modules_in_order: course_modules.map(&:id))
  end

  def setup_course_module(course)
    course_module = create_module(course)

    lessons = setup_lesson(course_module)
    quizzes = setup_quiz(course_module)

    course_module.update!(
      lessons_in_order: lessons.map(&:id),
      quizzes_in_order: quizzes.map(&:id)
    )

    course_module
  end

  def setup_lesson(course_module)
    Array.new(rand(1..10)) { create_lesson(course_module) }
  end


  def setup_quiz(course_module)
    sample_quizzes.sample(rand(1..4)).map { |quiz_data| create_quiz(*quiz_data, course_module) }
  end

  def create_course
    title = Faker::Lorem.sentence(word_count: 3)
    description = Faker::Lorem.paragraph(sentence_count: 4, supplemental: true)

    course = Course.create!(
      title:,
      description:,
      is_published: true
    )

    Thread.new do
      course.banner.attach(
        io: File.open(Rails.root.join("app/assets/images/#{STATIC_ASSETS[:course_banner]}")),
        filename: "course_banner.jpeg",
        content_type: "image/jpeg"
      )
    end
    course
  end

  def create_module(course)
    CourseModule.reset_column_information

    title = Faker::Lorem.sentence(word_count: 3)
    CourseModule.create!(
      title:,
      course:
    )
  end

  def create_lesson(course_module)
    Lesson.reset_column_information

    title = Faker::Lorem.sentence(word_count: 3)
    description = Faker::Lorem.paragraph(sentence_count: 4, supplemental: true)

    lesson = Lesson.new(title:, rich_description: description, duration: rand(1..10),
                   course_module:, local_contents_attributes: [{
                    lang: "english", blob_id: video_blob.id
                  }])
    CourseManagementService.instance.set_lesson_attributes(course_module, lesson)
    lesson.save!
    lesson
  end

  def create_quiz(question, a, b, c, d, answer, course_module)
    Quiz.create!(
      question:,
      option_a: a,
      option_b: b,
      option_c: c,
      option_d: d,
      answer:,
      course_module:
    )
  end

  def sample_quizzes
    [
    ['What does crossing your arms typically signify in body language?', 'Openness', 'Defensiveness', 'Happiness',
      'Interest', 'B'],
    ['Which of the following body language cues often indicates that a person is nervous or anxious?',
      'Leaning forward', 'Making direct eye contact', 'Fidgeting with objects', 'Smiling broadly', 'C'],
    ['When someone mirrors your body language, it generally means they are', 'Distracted', 'Disinterested',
      'Opposing you', 'Building rapport', 'D'],
    ['Standing with hands on hips is generally seen as a gesture of:', 'Submission', 'Dominance or confidence',
      'Confusion', 'Relaxation', 'B']
  ]
  end

  def video_blob
    @video_blob ||= ActiveStorage::Blob.create_and_upload!(
      io: Rails.root.join('spec/fixtures/files/sample_video.mp4').open,
      filename: 'sample_video.mp4',
      content_type: 'video/mp4'
    )
  end
end

DevelopmentSeed.instance.seed if Rails.env.development?
