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
      estimated_duration: 1800, status: 'VIDEO_READY', video_url: 'https://example.com/lesson.mp4', verified: true,
      scenes: [scene]
    )
  end

  let(:lesson_with_pending_scene) do
    pending_scene = ContentStudio::Scene.new(id: 's2', status: 'PENDING', video_url: nil,
                                             thumbnail_url: nil, duration: nil)
    ContentStudio::StructureLesson.new(
      id: '1', title: 'Introduction to Airport Services',
      estimated_duration: 1800, status: 'PENDING', video_url: nil, verified: false,
      scenes: [pending_scene]
    )
  end

  let(:unverified_lesson_with_scenes) do
    ContentStudio::StructureLesson.new(
      id: '1', title: 'Introduction to Airport Services',
      estimated_duration: 1800, status: 'VIDEO_READY', video_url: nil, verified: false,
      scenes: [scene]
    )
  end

  let(:verified_lesson_without_video) do
    ContentStudio::StructureLesson.new(
      id: '1', title: 'Introduction to Airport Services',
      estimated_duration: 1800, status: 'VIDEO_READY', video_url: nil, verified: true,
      scenes: [scene]
    )
  end

  before do
    allow(ContentStudio::ApiClient).to receive_messages(get_lesson: lesson, course_structure: structure)
  end

  describe 'DELETE /content_studio/courses/:course_id/lessons/:id' do
    context 'when deletion succeeds' do
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

      it 'sets a success flash notice' do
        expect(flash[:notice]).to eq('Lesson deleted successfully.')
      end
    end

    context 'when the lesson is locked' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_lesson).and_raise(Faraday::BadRequestError)
        delete '/content_studio/courses/1/lessons/1'
      end

      it 'redirects back to the lesson page' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
      end

      it 'sets an alert flash message' do
        expect(flash[:alert]).to eq('Lesson is currently being processed and cannot be deleted.')
      end
    end

    context 'when the lesson is not found' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_lesson).and_raise(Faraday::ResourceNotFound)
        delete '/content_studio/courses/1/lessons/1'
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets an alert flash message' do
        expect(flash[:alert]).to eq('Lesson not found.')
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_lesson).and_raise(Faraday::Error)
        delete '/content_studio/courses/1/lessons/1'
      end

      it 'redirects back to the lesson page' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
      end

      it 'sets an alert flash message' do
        expect(flash[:alert]).to eq('Something went wrong. Please try again.')
      end
    end
  end

  describe 'POST /content_studio/courses/:course_id/lessons/:id/verify' do
    context 'when verification succeeds' do
      before do
        allow(ContentStudio::ApiClient).to receive(:verify_lesson)
        post '/content_studio/courses/1/lessons/1/verify'
      end

      it 'calls ApiClient.verify_lesson with the correct ids' do
        expect(ContentStudio::ApiClient).to have_received(:verify_lesson).with('1', course_id: '1')
      end

      it 'redirects to the course structure page when there is no next lesson' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a success flash notice' do
        expect(flash[:notice]).to eq('Lesson verified.')
      end
    end

    context 'when a next_lesson_id is provided' do
      before do
        allow(ContentStudio::ApiClient).to receive(:verify_lesson)
        post '/content_studio/courses/1/lessons/1/verify', params: { next_lesson_id: '2' }
      end

      it 'redirects to the next lesson' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/2')
      end
    end

    context 'when the lesson is not found' do
      before do
        allow(ContentStudio::ApiClient).to receive(:verify_lesson).and_raise(Faraday::ResourceNotFound)
        post '/content_studio/courses/1/lessons/1/verify'
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets an alert flash message' do
        expect(flash[:alert]).to eq('Lesson not found.')
      end
    end

    context 'when the course is locked' do
      before do
        allow(ContentStudio::ApiClient).to receive(:verify_lesson).and_raise(Faraday::BadRequestError)
        post '/content_studio/courses/1/lessons/1/verify'
      end

      it 'redirects back to the lesson page' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
      end

      it 'sets an alert flash message' do
        expect(flash[:alert]).to eq('Course is currently being processed. Please wait before verifying.')
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(ContentStudio::ApiClient).to receive(:verify_lesson).and_raise(Faraday::Error)
        post '/content_studio/courses/1/lessons/1/verify'
      end

      it 'redirects back to the lesson page' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
      end

      it 'sets an alert flash message' do
        expect(flash[:alert]).to eq('Something went wrong while verifying. Please try again.')
      end
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

  describe 'GET /content_studio/courses/:course_id/lessons/:id/download' do
    context 'when the lesson video is available' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_lesson).and_return(lesson_with_scenes)
        stub_request(:get, 'https://example.com/lesson.mp4').to_return(
          status: 200, body: 'video-data', headers: { 'Content-Type' => 'video/mp4' }
        )
        get '/content_studio/courses/1/lessons/1/download'
      end

      it 'returns HTTP 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'sends the video as a file attachment' do
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include('.mp4')
      end
    end

    context 'when not all scenes are completed' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_lesson).and_return(lesson_with_pending_scene)
        get '/content_studio/courses/1/lessons/1/download'
      end

      it 'redirects back to the lesson page' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
      end

      it 'sets a not_available alert' do
        expected = 'The lesson video is not available yet. Please check back once processing is complete.'
        expect(flash[:alert]).to eq(expected)
      end
    end

    context 'when the lesson is not verified' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_lesson).and_return(unverified_lesson_with_scenes)
        get '/content_studio/courses/1/lessons/1/download'
      end

      it 'redirects back to the lesson page' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
      end

      it 'sets a not_verified alert' do
        expect(flash[:alert]).to eq('The lesson must be verified before it can be downloaded.')
      end
    end

    context 'when the lesson is verified but has no video url' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_lesson).and_return(verified_lesson_without_video)
        get '/content_studio/courses/1/lessons/1/download'
      end

      it 'redirects back to the lesson page' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
      end

      it 'sets a not_available alert' do
        expected = 'The lesson video is not available yet. Please check back once processing is complete.'
        expect(flash[:alert]).to eq(expected)
      end
    end

    context 'when the video link has expired' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_lesson).and_return(lesson_with_scenes)
        stub_request(:get, 'https://example.com/lesson.mp4').to_return(status: 403)
        get '/content_studio/courses/1/lessons/1/download'
      end

      it 'redirects back to the lesson page' do
        expect(response).to redirect_to('/content_studio/courses/1/lessons/1')
      end

      it 'sets an expired alert' do
        expected = 'The lesson video could not be downloaded. The link may have expired — please try again.'
        expect(flash[:alert]).to eq(expected)
      end
    end
  end

  describe 'PATCH /content_studio/courses/:course_id/lessons/:id/reorder' do
    context 'when reorder succeeds' do
      before do
        allow(ContentStudio::ApiClient).to receive(:reorder_lesson)
        patch '/content_studio/courses/1/lessons/1/reorder', params: { new_position: 2 }
      end

      it 'calls ApiClient.reorder_lesson with the correct args' do
        expect(ContentStudio::ApiClient).to have_received(:reorder_lesson).with('1', course_id: '1', new_position: 2)
      end

      it 'returns ok JSON' do
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq('status' => 'ok')
      end
    end

    context 'when the course is locked' do
      before do
        allow(ContentStudio::ApiClient).to receive(:reorder_lesson).and_raise(Faraday::BadRequestError)
        patch '/content_studio/courses/1/lessons/1/reorder', params: { new_position: 0 }
      end

      it 'returns bad_request status' do
        expect(response).to have_http_status(:bad_request)
      end

      it 'returns a locked error message' do
        expect(JSON.parse(response.body)['error']).to eq(
          'Course is currently being processed. Please wait before reordering.'
        )
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(ContentStudio::ApiClient).to receive(:reorder_lesson).and_raise(Faraday::Error)
        patch '/content_studio/courses/1/lessons/1/reorder', params: { new_position: 0 }
      end

      it 'returns unprocessable_entity status' do
        expect(response).to have_http_status(422)
      end

      it 'returns a generic error message' do
        expect(JSON.parse(response.body)['error']).to eq(
          'Something went wrong while reordering. Please try again.'
        )
      end
    end
  end
end
