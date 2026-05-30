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
end
