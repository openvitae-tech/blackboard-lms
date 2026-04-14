# frozen_string_literal: true

module ContentStudio
  class BlackboardClient
    BASE_PATH = '/api/internal'

    def list_courses
      response = connection.get("#{BASE_PATH}/courses")
      JSON.parse(response.body).map { |c| build_course(c) }
    end

    def find_course(id)
      response = connection.get("#{BASE_PATH}/courses/#{id}")
      build_course(JSON.parse(response.body))
    end

    def course_stats
      response = connection.get("#{BASE_PATH}/courses/stats")
      data = JSON.parse(response.body)
      CourseStats.new(
        created: data['created'],
        published: data['published'],
        in_progress: data['in_progress']
      )
    end

    def list_courses_by_status(status)
      response = connection.get("#{BASE_PATH}/courses", { studio_status: status, limit: 12 })
      JSON.parse(response.body).map { |c| build_course(c) }
    end

    def current_user
      response = connection.get("#{BASE_PATH}/users/me")
      build_user(JSON.parse(response.body))
    end

    private

    def connection
      @connection ||= Faraday.new(url: ContentStudio.base_url) do |f|
        f.request :json
        f.response :raise_error
      end
    end

    def build_course(data)
      Course.new(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        visibility: data['visibility'],
        is_published: data['is_published'],
        duration: data['duration'],
        rating: data['rating'],
        banner: data['banner'],
        categories: data['categories'],
        levels: data['levels'],
        course_modules_count: data['course_modules_count'],
        enrollments_count: data['enrollments_count'],
        team_enrollments_count: data['team_enrollments_count'],
        modules: (data['modules'] || []).map { |m| build_module(m) },
        progress: data['progress']
      )
    end

    def build_module(data)
      CourseModule.new(
        id: data['id'],
        title: data['title'],
        lessons_count: data['lessons_count'],
        quizzes_count: data['quizzes_count'],
        lessons: (data['lessons'] || []).map { |l| build_lesson(l) }
      )
    end

    def build_lesson(data)
      Lesson.new(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        duration: data['duration'],
        lesson_type: data['lesson_type'],
        rating: data['rating'],
        video_streaming_source: data['video_streaming_source'],
        local_contents: (data['local_contents'] || []).map { |lc| build_local_content(lc) }
      )
    end

    def build_local_content(data)
      LocalContent.new(
        id: data['id'],
        lang: data['lang'],
        status: data['status'],
        video_url: data['video_url'],
        video_published_at: data['video_published_at']
      )
    end

    def build_user(data)
      User.new(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        role: data['role']
      )
    end
  end
end
