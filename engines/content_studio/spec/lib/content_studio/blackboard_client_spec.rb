# frozen_string_literal: true

require_relative '../../rails_helper'

RSpec.describe ContentStudio::BlackboardClient do
  let(:base_url) { 'http://localhost:3000' }
  let(:client) { described_class.new }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:conn) do
    Faraday.new(url: base_url) do |f|
      f.request :json
      f.response :raise_error
      f.adapter :test, stubs
    end
  end

  before do
    allow(ContentStudio).to receive(:base_url).and_return(base_url)
    allow(client).to receive(:connection).and_return(conn)
  end

  describe '#initialize' do
    it 'forwards the session cookie in the connection header' do
      client_with_cookie = described_class.new(cookie: 'session=abc123')
      conn = client_with_cookie.send(:connection)
      expect(conn.headers['Cookie']).to eq('session=abc123')
    end

    it 'omits the Cookie header when no cookie is given' do
      conn = described_class.new.send(:connection)
      expect(conn.headers['Cookie']).to be_nil
    end
  end

  describe '#list_courses' do
    it 'returns an array of Course objects' do
      stubs.get('/api/internal/courses') do
        [200, { 'Content-Type' => 'application/json' },
         [{ 'id' => 'c1', 'title' => 'Course One' }].to_json]
      end
      result = client.list_courses
      expect(result).to be_an(Array)
      expect(result.first).to be_a(ContentStudio::Course)
      expect(result.first.id).to eq('c1')
    end
  end

  describe '#course_structure' do
    let(:structure_payload) do
      {
        'id' => 'c1', 'title' => 'My Course', 'duration' => nil,
        'thumbnail_url' => nil, 'progress_text' => 'Done', 'stage' => 'log_course_completed',
        'verified_modules_count' => 1,
        'modules' => [
          {
            'id' => 'm1', 'title' => 'Module 1',
            'lessons' => [
              {
                'id' => 'l1', 'title' => 'Lesson 1', 'description' => nil,
                'summary' => nil, 'estimated_duration' => nil,
                'status' => 'PENDING', 'video_url' => nil, 'verified' => false,
                'scenes' => [
                  { 'id' => 's1', 'timestamp' => '0:00', 'visual' => 'slide',
                    'narration' => 'Hello', 'status' => 'PENDING',
                    'video_url' => nil, 'thumbnail_url' => nil }
                ]
              }
            ]
          }
        ]
      }
    end

    it 'returns a CourseStructure with nested modules, lessons, and scenes' do
      stubs.get('/api/internal/courses/c1/structure') do
        [200, { 'Content-Type' => 'application/json' }, structure_payload.to_json]
      end
      result = client.course_structure('c1')
      expect(result).to be_a(ContentStudio::CourseStructure)
      expect(result.modules.first).to be_a(ContentStudio::StructureModule)
      lesson = result.modules.first.lessons.first
      expect(lesson).to be_a(ContentStudio::StructureLesson)
      expect(lesson.scenes.first).to be_a(ContentStudio::Scene)
      expect(lesson.scenes.first.id).to eq('s1')
    end
  end

  describe '#get_lesson' do
    let(:lesson_payload) do
      {
        'id' => 'l1', 'title' => 'Lesson 1', 'description' => nil,
        'summary' => nil, 'estimated_duration' => nil,
        'status' => 'PENDING', 'video_url' => nil, 'verified' => false, 'scenes' => []
      }
    end

    it 'returns a StructureLesson' do
      stubs.get('/api/internal/courses/c1/lessons/l1') do
        [200, { 'Content-Type' => 'application/json' }, lesson_payload.to_json]
      end
      result = client.get_lesson('c1', 'l1')
      expect(result).to be_a(ContentStudio::StructureLesson)
      expect(result.id).to eq('l1')
    end
  end

  describe '#regenerate_scene' do
    it 'posts to the correct URL with narration in the body' do
      stubs.post('/api/internal/courses/c1/lessons/l1/scenes/s1/regenerate') do |env|
        body = JSON.parse(env.body)
        expect(body['narration']).to eq('New text')
        [202, {}, '']
      end
      expect do
        client.regenerate_scene('s1', course_id: 'c1', lesson_id: 'l1', narration: 'New text')
      end.not_to raise_error
    end

    it 'raises Faraday::BadRequestError on 400' do
      stubs.post('/api/internal/courses/c1/lessons/l1/scenes/s1/regenerate') do
        [400, {}, 'duplicate narration']
      end
      expect do
        client.regenerate_scene('s1', course_id: 'c1', lesson_id: 'l1', narration: 'dupe')
      end.to raise_error(Faraday::BadRequestError)
    end
  end

  describe '#verify_lesson' do
    it 'posts to the correct URL' do
      stubs.post('/api/internal/courses/c1/lessons/l1/verify') do
        [200, {}, '{"status":"ok"}']
      end
      expect { client.verify_lesson('l1', course_id: 'c1') }.not_to raise_error
    end
  end

  describe '#generation_status' do
    it 'returns a GenerationStatus with status and stage' do
      stubs.get('/api/internal/courses/c1/generation_status') do
        [200, { 'Content-Type' => 'application/json' },
         { 'status' => 'PENDING', 'stage' => 'Generating…', 'redirect_url' => nil }.to_json]
      end
      result = client.generation_status('c1')
      expect(result).to be_a(ContentStudio::GenerationStatus)
      expect(result.status).to eq('PENDING')
      expect(result.stage).to eq('Generating…')
    end
  end
end
