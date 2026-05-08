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
      setup_users
      (0..10).each do
        setup_course
      end
      setup_tag
      setup_dashboard_data
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
        team:,
        country_code: AVAILABLE_COUNTRIES[:india][:code],
        state: 'active'
      )

      user.confirm
    end
  end

  def create_partner(name, about)
    partner = LearningPartner.create!(
      name:,
      content: about,
      supported_countries: [AVAILABLE_COUNTRIES[:india][:value]],
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

  def setup_users
    admins = [%w[Deepak admin]]
    other_users = [
      %w[Jubin owner],
      %w[Ajith manager],
      %w[Poornima learner]
    ]

    admins.each { |name, role| create_user(name, role) }
    partners = [
      ['The Grand Budapest Hotel', about_text],
      [Faker::Restaurant.name, about_text]
    ]

    partners.each { |name, about| create_partner(name, about) }

    partner = LearningPartner.first
    team = Team.where(learning_partner_id: partner.id).first

    other_users.each { |name, role| create_user(name, role, partner, team) }
  end

  def create_course
    title = Faker::Lorem.sentence(word_count: 3)
    description = Faker::Lorem.paragraph(sentence_count: 4, supplemental: true)

    course = Course.create!(
      title:,
      description:,
      is_published: true,
      visibility: "private"
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
    Courses::ManagementService.instance.set_lesson_attributes(course_module, lesson)
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

  def setup_dashboard_data
    partner = LearningPartner.first
    return unless partner

    team = Team.where(learning_partner_id: partner.id).first
    return unless team

    learners = User.where(team_id: team.id, role: User::LEARNER).active
    courses = Course.all.to_a
    return if learners.empty? || courses.empty?

    learners.each do |user|
      setup_time_spent_events(user, partner, team, courses)
      enrollments = setup_enrollments(user, courses)
      setup_quiz_answers(enrollments)
    end
  end

  def setup_time_spent_events(user, partner, team, courses)
    daily_hours = [2.5, 4.0, 3.2, 5.8, 4.5, 6.2, 3.8, 2.1, 4.8, 5.2, 3.6, 4.9, 5.5, 3.0]
    30.times do |days_ago|
      next if rand < 0.3 # skip ~30% of days for realism

      hours = daily_hours[days_ago % daily_hours.size]
      Event.create!(
        name: 'learning_time_spent',
        partner_id: partner.id,
        user_id: user.id,
        data: {
          team_id: team.id,
          user_id: user.id,
          course_id: courses.sample.id,
          time_spent: (hours * 3600).to_i
        },
        created_at: days_ago.days.ago
      )
    end
  end

  def setup_enrollments(user, courses)
    courses.sample(rand(3..6)).filter_map do |course|
      next if Enrollment.exists?(user: user, course: course)

      completed = [true, false, false].sample
      Enrollment.create!(
        user: user,
        course: course,
        course_completed: completed,
        course_started_at: rand(1..30).days.ago
      )
    end
  end

  def setup_quiz_answers(enrollments)
    enrollments.each do |enrollment|
      quizzes = Quiz.joins(:course_module)
                    .where(course_modules: { course_id: enrollment.course_id })
      quizzes.each do |quiz|
        next if QuizAnswer.exists?(quiz: quiz, enrollment: enrollment)

        status = ['correct', 'correct', 'incorrect'].sample
        QuizAnswer.create!(
          quiz: quiz,
          enrollment: enrollment,
          course_module_id: quiz.course_module_id,
          status: status,
          answer: %w[a b c d].sample,
          created_at: rand(1..30).days.ago
        )
      end
    end
  end

  def setup_tag
    category = ["Food", "Bar", "Restaurant"]
    level = ['Beginner', 'Advanced', 'Intermediate']

    category.each do |item|
      Tag.create!(name: item)
    end

    level.each do |item|
      Tag.create!(name: item, tag_type: :level)
    end
  end
end

DevelopmentSeed.instance.seed if Rails.env.development?
