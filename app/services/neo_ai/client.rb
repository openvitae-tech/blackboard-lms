# frozen_string_literal: true

module NeoAi
  class Client
    API_PREFIX = '/api/v1'
    TOKEN_EXPIRY_BUFFER = 10
    REQUEST_TIMEOUT = 30
    OPEN_TIMEOUT = 5

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

    def initialize(partner_id:)
      @partner_id = partner_id
      @token_mutex = Mutex.new
      @token = nil
      @token_expires_at = nil
    end

    def list_courses
      response = get('/course/list-courses')
      JSON.parse(response.body).fetch('courses', [])
    end

    def list_templates
      response = get('/course/list-templates')
      JSON.parse(response.body).fetch('templates', []).map do |t|
        { 'id' => t['template_id'], 'name' => t['name'], 'thumbnail_url' => t['thumbnail_url'] }
      end
    end

    def find_course(id)
      response = get("/course/#{id}")
      JSON.parse(response.body)
    end

    def create_course(files:, branding:, no_video: false)
      response = post('/course/create-course', { files: files, branding: branding }, no_video: no_video)
      JSON.parse(response.body)
    end

    def regenerate_scene(scene_id, course_id:, lesson_id:, narration:)
      post('/course/regenerate-scene',
           { scene_id: scene_id, course_id: course_id, lesson_id: lesson_id, narration: narration })
      {}
    end

    # NeoAI declares these as FastAPI Query(...) params, not Body — must be query string.
    def verify_lesson(lesson_id, course_id:)
      build_connection.post("#{API_PREFIX}/course/verify-lesson") do |req|
        req.params[:lesson_id] = lesson_id
        req.params[:course_id] = course_id
        req.params[:partner_id] = partner_id
      end
    end

    # NeoAI declares these as FastAPI Query(...) params, not Body — must be query string.
    def delete_course(course_id)
      build_connection.post("#{API_PREFIX}/course/delete-course") do |req|
        req.params[:course_id] = course_id
        req.params[:partner_id] = partner_id
      end
    end

    # NeoAI declares these as FastAPI Query(...) params, not Body — must be query string.
    def delete_lesson(lesson_id, course_id:)
      build_connection.post("#{API_PREFIX}/course/delete-lesson") do |req|
        req.params[:course_id] = course_id
        req.params[:lesson_id] = lesson_id
        req.params[:partner_id] = partner_id
      end
    end

    # NeoAI declares these as FastAPI Query(...) params, not Body — must be query string.
    def regenerate_lesson(lesson_id, course_id:)
      build_connection.post("#{API_PREFIX}/course/regenerate-scenes") do |req|
        req.params[:course_id] = course_id
        req.params[:lesson_id] = lesson_id
        req.params[:partner_id] = partner_id
      end
    end

    def stage_label(stage)
      STAGE_LABELS.fetch(stage.to_s, stage.to_s)
    end

    private

    def get(path)
      build_connection.get("#{API_PREFIX}#{path}", { partner_id: partner_id })
    end

    def post(path, body, no_video: false)
      build_connection.post("#{API_PREFIX}#{path}", body) do |req|
        req.params[:partner_id] = partner_id
        req.headers['No-Video'] = 'true' if no_video
      end
    end

    def build_connection
      token = current_token
      Faraday.new(url: NEO_AI_BASE_URL) do |f|
        f.options.timeout = REQUEST_TIMEOUT
        f.options.open_timeout = OPEN_TIMEOUT
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
      conn = Faraday.new(url: NEO_AI_BASE_URL) do |f|
        f.options.timeout = REQUEST_TIMEOUT
        f.options.open_timeout = OPEN_TIMEOUT
        f.response :raise_error
      end
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

    attr_reader :partner_id
  end
end
