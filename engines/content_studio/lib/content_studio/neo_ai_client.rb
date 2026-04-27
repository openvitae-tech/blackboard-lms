# frozen_string_literal: true

module ContentStudio
  class NeoAiClient
    API_PREFIX = '/api/v1'
    TOKEN_EXPIRY_BUFFER = 10 # seconds — refresh this early to avoid race conditions

    def initialize
      @token_mutex = Mutex.new
      @token = nil
      @token_expires_at = nil
    end

    # --- ApiClient interface ---

    def list_courses
      response = get('/course/list-courses')
      JSON.parse(response.body).fetch('courses', []).map { |c| build_course_summary(c) }
    end

    def list_courses_by_status(status)
      list_courses.select { |c| c.status == status }
    end

    def find_course(id)
      response = get("/course/#{id}")
      build_neo_course(JSON.parse(response.body))
    end

    def course_stats
      courses = list_courses
      CourseStats.new(
        created: courses.count { |c| c.status == 'created' },
        published: courses.count { |c| c.status == 'published' },
        in_progress: courses.count { |c| c.status == 'in_progress' }
      )
    end

    STAGE_LABELS = {
      'accepted' => 'Preparing your course…',
      'upload_artifacts' => 'Uploading documents…',
      'upload_artifacts_completed' => 'Documents uploaded',
      'upload_artifacts_failed' => 'Failed to upload documents',
      'create_course_structure' => 'Building course structure…',
      'create_course_structure_completed' => 'Course structure ready',
      'create_course_structure_failed' => 'Failed to build course structure',
      'scene_writer' => 'Writing lesson scripts…',
      'scene_writer_completed' => 'Lesson scripts ready',
      'scene_writer_failed' => 'Failed to write scripts',
      'video_generation' => 'Generating videos…',
      'video_generation_completed' => 'Videos generated',
      'video_generation_failed' => 'Failed to generate videos',
      'log_course' => 'Finalising your course…',
      'log_course_completed' => 'Course is ready!',
      'log_course_failed' => 'Something went wrong'
    }.freeze

    def generation_status(course_id)
      response = get("/course/#{course_id}")
      data = JSON.parse(response.body)
      structure_ready = data.fetch('modules', []).any?
      stage_text = data['progress_text'].presence || STAGE_LABELS.fetch(data['stage'], data['stage'])
      GenerationStatus.new(
        status: structure_ready ? 'COMPLETED' : 'PENDING',
        stage: stage_text,
        redirect_url: nil
      )
    end

    def course_structure(course_id)
      response = get("/course/#{course_id}")
      build_course_structure(JSON.parse(response.body))
    end

    def get_lesson(course_id, lesson_id)
      response = get("/course/#{course_id}")
      data = JSON.parse(response.body)
      lesson_data = data.fetch('modules', [])
                        .flat_map { |m| m.fetch('lessons', []) }
                        .find { |l| l['id'] == lesson_id }
      lesson_data ? build_structure_lesson(lesson_data) : nil
    end

    def create_course(files:, branding:)
      response = post('/course/create-course', { files: files, branding: branding })
      data = JSON.parse(response.body)
      data['course_id'] || data['id']
    end

    def regenerate_scene(course_id, lesson_id, scene_id, narration:)
      post(
        "/course/#{course_id}/lesson/#{lesson_id}/scene/#{scene_id}/regenerate",
        { narration: narration }
      )
    end

    # Stubs — no NeoAI equivalent for these BlackboardLMS-specific calls
    def current_user = User.new(id: nil, name: nil, email: nil, role: nil)
    def list_avatars = []
    def list_templates = []

    def course_metadata
      CourseMetadata.new(categories: [],
                         languages: %w[English Hindi
                                       Tamil Telugu Kannada Malayalam Marathi Bengali Gujarati Punjabi])
    end

    def save_course(_course_id) = nil
    def discard_course(_course_id) = nil

    private

    def get(path)
      build_connection.get("#{API_PREFIX}#{path}", { partner_id: partner_id })
    end

    def post(path, body)
      build_connection.post("#{API_PREFIX}#{path}", body) do |req|
        req.params[:partner_id] = partner_id
      end
    end

    def build_connection
      token = current_token
      Faraday.new(url: neo_ai_base_url) do |f|
        f.request :json
        f.response :raise_error
        f.headers['Authorization'] = "Bearer #{token}"
        f.headers['Accept'] = 'application/json'
      end
    end

    def current_token
      @token_mutex.synchronize do
        refresh_token if token_expired?
        @token
      end
    end

    def token_expired?
      @token.nil? || Time.current.to_i >= @token_expires_at
    end

    def refresh_token
      conn = Faraday.new(url: neo_ai_base_url) { |f| f.response :raise_error }
      response = conn.get("#{API_PREFIX}/token") do |req|
        req.headers['x-client-secret'] = NEO_AI_CLIENT_SECRET
      end
      data = JSON.parse(response.body)
      @token = data['access_token']
      @token_expires_at = jwt_exp(@token) - TOKEN_EXPIRY_BUFFER
    end

    def jwt_exp(token)
      payload_b64 = token.split('.')[1]
      padded = payload_b64 + ('=' * ((4 - (payload_b64.length % 4)) % 4))
      JSON.parse(Base64.urlsafe_decode64(padded)).fetch('exp')
    end

    def neo_ai_base_url = NEO_AI_BASE_URL

    def partner_id = NEO_AI_PARTNER_ID

    # --- Builders ---

    def build_course_summary(data)
      Course.new(
        id: data['course_id'],
        title: data['title'],
        status: map_course_status(data['status']),
        thumbnail_url: data['thumbnail_url']
      )
    end

    def map_course_status(raw)
      case raw&.upcase
      when 'COMPLETED' then 'verified'
      else 'to_be_verified'
      end
    end

    def build_neo_course(data)
      Course.new(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        status: data['status'],
        modules: (data['modules'] || []).map { |m| build_neo_module(m) }
      )
    end

    def build_neo_module(data)
      CourseModule.new(
        id: data['id'],
        title: data['title'],
        lessons: (data['lessons'] || []).map { |l| build_neo_lesson(l) }
      )
    end

    def build_neo_lesson(data)
      Lesson.new(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        duration: data['estimated_duration'],
        scenes: (data['scenes'] || []).map { |s| build_scene(s) }
      )
    end

    def build_scene(data)
      Scene.new(
        id: data['id'],
        timestamp: data['timestamp'],
        visual: data['visual'],
        narration: data['narration'],
        status: data['status'],
        video_url: data['video_url'],
        thumbnail_url: data['thumbnail_url']
      )
    end

    def build_course_structure(data)
      CourseStructure.new(
        id: data['id'],
        title: data['title'],
        modules: (data['modules'] || []).map { |m| build_structure_module(m) },
        verified_modules_count: 0,
        thumbnail_url: data['thumbnail_url']
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
      scenes = (data['scenes'] || []).map { |s| build_scene(s) }
      StructureLesson.new(
        id: data['id'],
        title: data['title'],
        description: data['description'],
        summary: data['summary'],
        estimated_duration: data['estimated_duration'],
        status: derive_lesson_status(scenes),
        video_url: data['video_url'],
        scenes: scenes
      )
    end

    def derive_lesson_status(scenes)
      return 'WAITING' if scenes.empty?
      return 'COMPLETED' if scenes.all? { |s| s.video_url.present? }
      return 'PENDING' if scenes.any? { |s| s.video_url.blank? && s.status == 'PENDING' }

      'WAITING'
    end
  end
end
