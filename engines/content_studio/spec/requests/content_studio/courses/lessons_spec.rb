# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Courses::Lessons', type: :request do
  let(:lesson) do
    ContentStudio::StructureLesson.new(
      id: '1',
      title: 'Introduction to Airport Services',
      description: 'This lesson introduces the core concepts of airport services management.',
      estimated_duration: 1800,
      status: 'PENDING',
      video_url: nil,
      verified: false,
      scenes: []
    )
  end

  let(:structure) do
    ContentStudio::CourseStructure.new(
      id: '1',
      title: 'Test Course',
      modules: [
        ContentStudio::StructureModule.new(
          id: 'm1',
          title: 'Module 1',
          lessons: [
            ContentStudio::StructureLesson.new(id: '1', title: 'Introduction to Airport Services',
                                               status: 'PENDING', scenes: []),
            ContentStudio::StructureLesson.new(id: '2', title: 'Rules and Regulations',
                                               status: 'PENDING', scenes: [])
          ]
        )
      ],
      verified_modules_count: 0,
      thumbnail_url: nil
    )
  end

  let(:scene) do
    ContentStudio::Scene.new(id: 's1', status: 'COMPLETED', video_url: 'https://example.com/s1.mp4',
                             thumbnail_url: 'https://example.com/thumb.jpg', duration: 90)
  end

  let(:lesson_with_scenes) do
    ContentStudio::StructureLesson.new(
      id: '1', title: 'Introduction to Airport Services',
      estimated_duration: 1800, status: 'VIDEO_READY', video_url: nil, verified: false,
      scenes: [scene]
    )
  end

  before do
    allow(ContentStudio::ApiClient).to receive_messages(get_lesson: lesson, course_structure: structure)
  end

  describe 'DELETE /content_studio/courses/:course_id/lessons/:id' do
    before do
      allow(ContentStudio::ApiClient).to receive(:delete_lesson)
      delete '/content_studio/courses/1/lessons/1'
    end

    it 'calls ApiClient.delete_lesson with the correct ids' do
      expect(ContentStudio::ApiClient).to have_received(:delete_lesson).with('1', course_id: '1')
    end

    it 'redirects to the course structure page' do
      expect(response).to redirect_to('/content_studio/courses/1/structure')
    end
  end

  describe 'POST /content_studio/courses/:course_id/lessons/:id/regenerate' do
    before do
      allow(ContentStudio::ApiClient).to receive(:regenerate_lesson)
      post '/content_studio/courses/1/lessons/1/regenerate'
    end

    it 'calls ApiClient.regenerate_lesson with the correct ids' do
      expect(ContentStudio::ApiClient).to have_received(:regenerate_lesson).with('1', course_id: '1')
    end

    it 'redirects back to the lesson page' do
      expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
    end
  end

  describe 'GET /content_studio/courses/:course_id/lessons/:id' do
    before { get '/content_studio/courses/1/lessons/1' }

    it 'returns HTTP 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the Lesson Page heading' do
      expect(response.body).to include('Lesson Page')
    end

    it 'renders the lesson title in the info panel' do
      expect(response.body).to include('Introduction to Airport Services')
    end

    it 'renders the Previous and Next navigation buttons' do
      expect(response.body).to include('Previous')
      expect(response.body).to include('Next')
    end

    it 'renders the Show more toggle' do
      expect(response.body).to include('Show more')
    end
  end

  describe 'GET /content_studio/courses/:course_id/lessons/:id/scene_status' do
    before do
      allow(ContentStudio::ApiClient).to receive(:get_lesson).and_return(lesson_with_scenes)
      get '/content_studio/courses/1/lessons/1/scene_status', headers: { 'Accept' => 'application/json' }
    end

    it 'returns HTTP 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'returns scene status, video_url, thumbnail_url, and duration for each scene' do
      body = response.parsed_body
      scene_data = body['scenes'].first
      expect(scene_data['id']).to eq('s1')
      expect(scene_data['status']).to eq('COMPLETED')
      expect(scene_data['video_url']).to eq('https://example.com/s1.mp4')
      expect(scene_data['thumbnail_url']).to eq('https://example.com/thumb.jpg')
      expect(scene_data['duration']).to eq(90)
    end

    it 'returns pending: false when all scenes have a video_url' do
      expect(response.parsed_body['pending']).to be(false)
    end

    it 'returns pending: true when a scene has no video_url' do
      pending_scene = ContentStudio::Scene.new(id: 's1', status: 'PENDING', video_url: nil,
                                               thumbnail_url: nil, duration: nil)
      pending_lesson = ContentStudio::StructureLesson.new(
        id: '1', title: 'Intro', estimated_duration: 0, status: 'PENDING',
        video_url: nil, verified: false, scenes: [pending_scene]
      )
      allow(ContentStudio::ApiClient).to receive(:get_lesson).and_return(pending_lesson)
      get '/content_studio/courses/1/lessons/1/scene_status', headers: { 'Accept' => 'application/json' }
      expect(response.parsed_body['pending']).to be(true)
    end
  end
end
