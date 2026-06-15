# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Internal::Courses', type: :request do
  let(:privileged_user) { create(:user, :owner) }
  let(:learner) { create(:user, :learner) }
  let(:neo_ai) { instance_double(NeoAi::Client) }

  before do
    stub_const('NEO_AI_PARTNER_HMAC_SECRET', 'test-secret')
    Api::Internal::CoursesController.instance_variable_set(:@neo_ai_client, nil)
    allow(NeoAi::Client).to receive(:new).and_return(neo_ai)
  end

  describe 'authentication and authorization' do
    it 'returns 401 when not signed in' do
      get '/api/internal/courses'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for non-privileged users' do
      sign_in learner
      get '/api/internal/courses'
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/internal/courses' do
    let(:courses) do
      [
        { 'id' => 'c1', 'title' => 'Course One', 'status' => 'PENDING' },
        { 'id' => 'c2', 'title' => 'Course Two', 'status' => 'COMPLETED' }
      ]
    end

    before do
      sign_in privileged_user
      allow(neo_ai).to receive(:list_courses).and_return(courses)
    end

    it 'returns all courses when no status filter' do
      get '/api/internal/courses'
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.length).to eq(2)
    end

    it 'filters by completed status' do
      get '/api/internal/courses', params: { studio_status: 'completed' }
      ids = response.parsed_body.map { |c| c['id'] }
      expect(ids).to eq(['c2'])
    end

    it 'filters in_progress (PENDING only)' do
      get '/api/internal/courses', params: { studio_status: 'in_progress' }
      ids = response.parsed_body.map { |c| c['id'] }
      expect(ids).to eq(['c1'])
    end

    it 'returns empty array for unknown studio_status' do
      get '/api/internal/courses', params: { studio_status: 'unknown' }
      expect(response.parsed_body).to eq([])
    end

    it 'respects the limit param' do
      get '/api/internal/courses', params: { limit: 1 }
      expect(response.parsed_body.length).to eq(1)
    end

    it 'maps status to studio status in response' do
      get '/api/internal/courses'
      statuses = response.parsed_body.map { |c| c['status'] }
      expect(statuses).to eq(%w[in_progress completed])
    end
  end

  describe 'GET /api/internal/courses/stats' do
    before do
      sign_in privileged_user
      allow(neo_ai).to receive(:list_courses).and_return([
                                                           { 'status' => 'PENDING' },
                                                           { 'status' => 'PENDING' },
                                                           { 'status' => 'COMPLETED' }
                                                         ])
    end

    it 'returns created, published, in_progress counts' do
      get '/api/internal/courses/stats'
      body = response.parsed_body
      expect(body['created']).to eq(1)
      expect(body['published']).to eq(0)
      expect(body['in_progress']).to eq(2)
    end
  end

  describe 'GET /api/internal/courses/:id/generation_status' do
    before { sign_in privileged_user }

    it 'returns PENDING when no modules and stage is not log_course_completed' do
      data = { 'stage' => 'scene_writer', 'modules' => [], 'progress_text' => nil }
      allow(neo_ai).to receive(:find_course).with('c1').and_return(data)
      allow(neo_ai).to receive(:stage_label).with('scene_writer').and_return('Writing lesson scripts…')
      get '/api/internal/courses/c1/generation_status'
      expect(response.parsed_body['status']).to eq('PENDING')
    end

    it 'returns COMPLETED when modules are present' do
      data = { 'stage' => 'video_generation', 'modules' => [{ 'id' => 'm1' }], 'progress_text' => nil }
      allow(neo_ai).to receive(:find_course).with('c1').and_return(data)
      allow(neo_ai).to receive(:stage_label).with('video_generation').and_return('Generating videos…')
      get '/api/internal/courses/c1/generation_status'
      expect(response.parsed_body['status']).to eq('COMPLETED')
    end

    it 'returns COMPLETED when stage is log_course_completed' do
      data = { 'stage' => 'log_course_completed', 'modules' => [], 'progress_text' => nil }
      allow(neo_ai).to receive(:find_course).with('c1').and_return(data)
      allow(neo_ai).to receive(:stage_label).with('log_course_completed').and_return('Course is ready!')
      get '/api/internal/courses/c1/generation_status'
      expect(response.parsed_body['status']).to eq('COMPLETED')
    end

    it 'uses progress_text when present' do
      data = { 'stage' => 'scene_writer', 'modules' => [], 'progress_text' => 'Almost there…' }
      allow(neo_ai).to receive(:find_course).with('c1').and_return(data)
      get '/api/internal/courses/c1/generation_status'
      expect(response.parsed_body['stage']).to eq('Almost there…')
    end
  end

  describe 'GET /api/internal/courses/:id/structure' do
    let(:structure_data) do
      {
        'id' => 'c1', 'title' => 'My Course', 'thumbnail_url' => nil,
        'progress_text' => nil, 'stage' => 'log_course_completed',
        'modules' => [
          {
            'id' => 'm1', 'title' => 'Module 1',
            'lessons' => [
              {
                'id' => 'l1', 'title' => 'Lesson 1', 'description' => nil,
                'summary' => nil, 'estimated_duration' => nil,
                'video_url' => 'https://example.com/video.mp4',
                'verified' => true,
                'scenes' => [{ 'id' => 's1', 'video_url' => 'https://example.com/s1.mp4' }]
              }
            ]
          }
        ]
      }
    end

    before do
      sign_in privileged_user
      allow(neo_ai).to receive(:find_course).with('c1').and_return(structure_data)
    end

    it 'returns the course structure' do
      get '/api/internal/courses/c1/structure'
      body = response.parsed_body
      expect(body['id']).to eq('c1')
      expect(body['modules'].length).to eq(1)
      expect(body['modules'][0]['lessons'].length).to eq(1)
    end

    it 'counts verified lessons' do
      get '/api/internal/courses/c1/structure'
      expect(response.parsed_body['verified_modules_count']).to eq(1)
    end
  end

  describe 'POST /api/internal/courses' do
    before do
      sign_in privileged_user
      allow(neo_ai).to receive(:create_course).and_return({ 'course_id' => 'new-c1' })
    end

    it 'returns the new course_id' do
      post '/api/internal/courses', params: { files: [], branding: {} }
      expect(response.parsed_body['course_id']).to eq('new-c1')
    end
  end

  describe 'PATCH /api/internal/courses/:id/save' do
    let(:neo_ai_data) do
      {
        'title' => 'AI Generated Course',
        'description' => 'An AI generated course about a very interesting topic for learners',
        'modules' => [
          {
            'id' => 'm1',
            'title' => 'Module One',
            'lessons' => [
              {
                'id' => 'l1',
                'title' => 'Lesson One',
                'description' => 'Intro lesson',
                'estimated_duration' => 60,
                'video_url' => 'https://example.com/video.mp4'
              }
            ]
          }
        ]
      }
    end

    before do
      sign_in privileged_user
      allow(neo_ai).to receive(:find_course).with('c1').and_return(neo_ai_data)
    end

    it 'returns ok' do
      patch '/api/internal/courses/c1/save'
      expect(response).to have_http_status(:ok)
    end

    it 'creates a course in BlackboardLMS' do
      expect { patch '/api/internal/courses/c1/save' }.to change(Course, :count).by(1)
    end

    it 'persists the course title and neo_ai_course_id' do
      patch '/api/internal/courses/c1/save'
      course = Course.last
      expect(course.title).to eq('AI Generated Course')
      expect(course.neo_ai_course_id).to eq('c1')
    end

    it 'creates modules and lessons' do
      patch '/api/internal/courses/c1/save'
      course = Course.last
      expect(course.course_modules.count).to eq(1)
      expect(course.course_modules.first.lessons.count).to eq(1)
    end

    it 'is idempotent on repeated calls' do
      patch '/api/internal/courses/c1/save'
      expect { patch '/api/internal/courses/c1/save' }.not_to change(Course, :count)
    end
  end

  describe 'DELETE /api/internal/courses/:id' do
    it 'deletes the course and returns 204' do
      sign_in privileged_user
      allow(neo_ai).to receive(:delete_course).with('c1')
      delete '/api/internal/courses/c1'
      expect(response).to have_http_status(:no_content)
      expect(neo_ai).to have_received(:delete_course).with('c1')
    end
  end

  describe 'POST /api/internal/courses/:course_id/lessons/:lesson_id/scenes/:scene_id/regenerate' do
    before { sign_in privileged_user }

    it 'calls neo_ai.regenerate_scene and returns ok' do
      allow(neo_ai).to receive(:regenerate_scene)
      post '/api/internal/courses/c1/lessons/l1/scenes/s1/regenerate',
           params: { narration: 'New narration' }
      expect(neo_ai).to have_received(:regenerate_scene)
        .with('s1', course_id: 'c1', lesson_id: 'l1', narration: 'New narration')
      expect(response).to have_http_status(:ok)
    end

    it 'propagates upstream errors from NeoAI' do
      faraday_response = { status: 400, body: 'bad request', headers: {} }
      err = Faraday::BadRequestError.new(nil, faraday_response)
      allow(neo_ai).to receive(:regenerate_scene).and_raise(err)
      post '/api/internal/courses/c1/lessons/l1/scenes/s1/regenerate',
           params: { narration: 'dupe' }
      expect(response).to have_http_status(:bad_request)
    end
  end

  describe 'POST /api/internal/courses/:course_id/lessons/:lesson_id/verify' do
    before { sign_in privileged_user }

    it 'calls neo_ai.verify_lesson and returns ok' do
      allow(neo_ai).to receive(:verify_lesson)
      post '/api/internal/courses/c1/lessons/l1/verify'
      expect(neo_ai).to have_received(:verify_lesson).with('l1', course_id: 'c1')
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'BaseController#render_upstream_error' do
    before { sign_in privileged_user }

    it 'forwards the upstream status code when NeoAI returns an error response' do
      err = Faraday::ServerError.new(nil, { status: 503, body: 'service unavailable', headers: {} })
      allow(neo_ai).to receive(:list_courses).and_raise(err)
      get '/api/internal/courses'
      expect(response).to have_http_status(503)
    end

    it 'returns 502 when Faraday raises a connection-level error with no response' do
      allow(neo_ai).to receive(:list_courses).and_raise(Faraday::ConnectionFailed.new('connection refused'))
      get '/api/internal/courses'
      expect(response).to have_http_status(:bad_gateway)
    end
  end
end
