# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::Internal::Courses::Lessons', type: :request do
  let(:privileged_user) { create(:user, :owner) }
  let(:course_data) do
    {
      'modules' => [
        {
          'lessons' => [
            {
              'id' => 'l1',
              'title' => 'Lesson One',
              'description' => 'Desc',
              'summary' => 'Summary',
              'estimated_duration' => 300,
              'video_url' => nil,
              'verified' => false,
              'scenes' => [
                { 'id' => 's1', 'narration' => 'Hello', 'video_url' => nil,
                  'timestamp' => '0:00', 'visual' => 'slide', 'status' => 'PENDING',
                  'thumbnail_url' => nil, 'duration' => 90 }
              ]
            }
          ]
        }
      ]
    }
  end
  let(:learner) { create(:user, :learner) }
  let(:neo_ai) { instance_double(NeoAi::Client) }

  before do
    Api::Internal::Courses::LessonsController.instance_variable_set(:@neo_ai_client, nil)
    allow(NeoAi::Client).to receive(:new).and_return(neo_ai)
  end

  describe 'authentication and authorization' do
    it 'returns 401 when not signed in' do
      get '/api/internal/courses/c1/lessons/l1'
      expect(response).to have_http_status(:unauthorized)
    end

    it 'returns 403 for non-privileged users' do
      sign_in learner
      get '/api/internal/courses/c1/lessons/l1'
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'GET /api/internal/courses/:course_id/lessons/:id' do
    before { sign_in privileged_user }

    it 'returns the lesson with scenes' do
      allow(neo_ai).to receive(:find_course).with('c1').and_return(course_data)
      get '/api/internal/courses/c1/lessons/l1'
      body = response.parsed_body
      expect(response).to have_http_status(:ok)
      expect(body['id']).to eq('l1')
      expect(body['scenes'].length).to eq(1)
    end

    it 'includes duration in each scene' do
      allow(neo_ai).to receive(:find_course).with('c1').and_return(course_data)
      get '/api/internal/courses/c1/lessons/l1'
      expect(response.parsed_body['scenes'].first['duration']).to eq(90)
    end

    it 'returns 404 when the lesson is not in the course' do
      allow(neo_ai).to receive(:find_course).with('c1').and_return(course_data)
      get '/api/internal/courses/c1/lessons/missing'
      expect(response).to have_http_status(:not_found)
    end

    it 'derives PENDING status when scenes exist but no videos' do
      allow(neo_ai).to receive(:find_course).with('c1').and_return(course_data)
      get '/api/internal/courses/c1/lessons/l1'
      expect(response.parsed_body['status']).to eq('PENDING')
    end

    it 'derives WAITING status when there are no scenes' do
      data = course_data.deep_dup
      data['modules'][0]['lessons'][0]['scenes'] = []
      allow(neo_ai).to receive(:find_course).with('c1').and_return(data)
      get '/api/internal/courses/c1/lessons/l1'
      expect(response.parsed_body['status']).to eq('WAITING')
    end

    it 'derives VIDEO_READY when all scenes have video_url' do
      data = course_data.deep_dup
      data['modules'][0]['lessons'][0]['scenes'][0]['video_url'] = 'https://example.com/s1.mp4'
      allow(neo_ai).to receive(:find_course).with('c1').and_return(data)
      get '/api/internal/courses/c1/lessons/l1'
      expect(response.parsed_body['status']).to eq('VIDEO_READY')
    end

    it 'derives VERIFIED when verified and video_url present' do
      data = course_data.deep_dup
      data['modules'][0]['lessons'][0]['verified'] = true
      data['modules'][0]['lessons'][0]['video_url'] = 'https://example.com/lesson.mp4'
      allow(neo_ai).to receive(:find_course).with('c1').and_return(data)
      get '/api/internal/courses/c1/lessons/l1'
      expect(response.parsed_body['status']).to eq('VERIFIED')
    end
  end
end
