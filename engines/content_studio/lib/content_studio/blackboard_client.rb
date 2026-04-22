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

    def list_avatars
      response = connection.get("#{BASE_PATH}/courses/avatars")
      JSON.parse(response.body).map do |a|
        Avatar.new(id: a['id'], name: a['name'], image_url: a['image_url'])
      end
    end

    def list_templates
      response = connection.get("#{BASE_PATH}/courses/templates")
      JSON.parse(response.body).map do |t|
        VideoTemplate.new(id: t['id'], name: t['name'], thumbnail_url: t['thumbnail_url'])
      end
    end

    def course_metadata
      response = connection.get("#{BASE_PATH}/courses/metadata")
      data = JSON.parse(response.body)
      CourseMetadata.new(
        categories: data['categories'],
        languages: data['languages']
      )
    end

    def generation_status(course_id)
      response = connection.get("#{BASE_PATH}/courses/#{course_id}/generation_status")
      data = JSON.parse(response.body)
      GenerationStatus.new(status: data['status'], redirect_url: data['redirect_url'])
    end

    def course_structure(course_id)
      response = connection.get("#{BASE_PATH}/courses/#{course_id}/structure")
      build_course_structure(JSON.parse(response.body))
    end

    def save_course(course_id)
      connection.patch("#{BASE_PATH}/courses/#{course_id}/save")
    end

    def discard_course(course_id)
      connection.delete("#{BASE_PATH}/courses/#{course_id}")
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

    def build_course_structure(data)
      CourseStructure.new(
        id: data['id'],
        title: data['title'],
        duration: data['duration'],
        modules: (data['modules'] || []).map { |m| build_structure_module(m) },
        verified_modules_count: data['verified_modules_count'].to_i,
        banner_url: data['banner_url']
      )
    end

    def build_structure_module(data)
      StructureModule.new(
        id: data['id'],
        title: data['title'],
        lessons: (data['lessons'] || []).map { |l| build_structure_lesson(l) }
      )
    end

    def build_structure_lesson(data)
      StructureLesson.new(id: data['id'], title: data['title'], status: data['status'])
    end
  end
end
