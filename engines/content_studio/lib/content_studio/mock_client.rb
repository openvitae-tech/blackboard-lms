# frozen_string_literal: true

module ContentStudio
  class MockClient
    def list_courses
      MOCK_COURSES
    end

    def find_course(id)
      MOCK_COURSES.find { |c| c.id == id.to_i }
    end

    def current_user
      MOCK_USER
    end

    MOCK_USER = User.new(
      id: 1,
      name: 'Demo User',
      email: 'demo@example.com',
      role: 'admin'
    ).freeze

    MOCK_COURSES = [
      Course.new(
        id: 1,
        title: 'Introduction to Ruby on Rails',
        description: 'A comprehensive beginner course covering Rails fundamentals, ' \
                     'MVC architecture, and building your first web application.',
        visibility: 'public',
        is_published: true,
        duration: 7200,
        rating: 4.5,
        banner: nil,
        categories: ['Engineering'],
        levels: ['Beginner'],
        course_modules_count: 2,
        enrollments_count: 120,
        team_enrollments_count: 5,
        modules: [
          CourseModule.new(
            id: 1,
            title: 'Getting Started',
            lessons_count: 2,
            quizzes_count: 1,
            lessons: [
              Lesson.new(
                id: 1,
                title: 'What is Rails?',
                description: 'Overview of the Rails framework and its conventions.',
                duration: 1800,
                lesson_type: 'video',
                rating: 4.6,
                video_streaming_source: 'youtube',
                local_contents: [
                  LocalContent.new(id: 1, lang: 'en', status: 'published', video_url: nil, video_published_at: nil)
                ]
              ),
              Lesson.new(
                id: 2,
                title: 'Setting Up Your Environment',
                description: 'Install Ruby, Rails, and configure your development environment.',
                duration: 1800,
                lesson_type: 'video',
                rating: 4.4,
                video_streaming_source: 'youtube',
                local_contents: [
                  LocalContent.new(id: 2, lang: 'en', status: 'published', video_url: nil, video_published_at: nil)
                ]
              )
            ]
          ),
          CourseModule.new(
            id: 2,
            title: 'MVC Deep Dive',
            lessons_count: 2,
            quizzes_count: 0,
            lessons: [
              Lesson.new(
                id: 3,
                title: 'Models and ActiveRecord',
                description: 'Understanding database-backed models and ActiveRecord conventions.',
                duration: 1800,
                lesson_type: 'video',
                rating: 4.7,
                video_streaming_source: 'youtube',
                local_contents: [
                  LocalContent.new(id: 3, lang: 'en', status: 'published', video_url: nil, video_published_at: nil)
                ]
              ),
              Lesson.new(
                id: 4,
                title: 'Controllers and Views',
                description: 'How requests flow through controllers and get rendered as views.',
                duration: 1800,
                lesson_type: 'video',
                rating: 4.5,
                video_streaming_source: 'youtube',
                local_contents: [
                  LocalContent.new(id: 4, lang: 'en', status: 'published', video_url: nil, video_published_at: nil)
                ]
              )
            ]
          )
        ]
      ),
      Course.new(
        id: 2,
        title: 'Advanced JavaScript Patterns',
        description: 'Explore advanced JavaScript design patterns, async programming, ' \
                     'and modern ES6+ features for professional developers.',
        visibility: 'public',
        is_published: false,
        duration: 5400,
        rating: 4.2,
        banner: nil,
        categories: ['Engineering'],
        levels: ['Advanced'],
        course_modules_count: 1,
        enrollments_count: 45,
        team_enrollments_count: 2,
        modules: [
          CourseModule.new(
            id: 3,
            title: 'Async JavaScript',
            lessons_count: 2,
            quizzes_count: 1,
            lessons: [
              Lesson.new(
                id: 5,
                title: 'Promises and Async/Await',
                description: 'Master asynchronous JavaScript with promises and async/await patterns.',
                duration: 2700,
                lesson_type: 'video',
                rating: 4.3,
                video_streaming_source: 'youtube',
                local_contents: [
                  LocalContent.new(id: 5, lang: 'en', status: 'draft', video_url: nil, video_published_at: nil)
                ]
              ),
              Lesson.new(
                id: 6,
                title: 'Event Loop and Concurrency',
                description: 'Deep dive into the JavaScript event loop and concurrency model.',
                duration: 2700,
                lesson_type: 'video',
                rating: 4.1,
                video_streaming_source: 'youtube',
                local_contents: [
                  LocalContent.new(id: 6, lang: 'en', status: 'draft', video_url: nil, video_published_at: nil)
                ]
              )
            ]
          )
        ]
      )
    ].freeze
  end
end
