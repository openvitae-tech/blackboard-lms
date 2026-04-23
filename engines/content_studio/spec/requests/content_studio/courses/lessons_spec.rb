# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Courses::Lessons', type: :request do
  let(:local_content) do
    ContentStudio::LocalContent.new(
      id: 1, lang: 'en', status: 'published', video_url: nil, video_published_at: nil
    )
  end

  let(:lesson) do
    ContentStudio::Lesson.new(
      id: 1,
      title: 'Introduction to Airport Services',
      description: 'This lesson introduces the core concepts of airport services management.',
      duration: 1800,
      lesson_type: 'video',
      rating: 4.8,
      video_streaming_source: 'youtube',
      local_contents: [local_content]
    )
  end

  before do
    allow(ContentStudio::ApiClient).to receive(:get_lesson).and_return(lesson)
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

    it 'renders the Edit Video Style button' do
      expect(response.body).to include('Edit Video Style')
    end

    it 'renders the Delete Lesson button' do
      expect(response.body).to include('Delete Lesson')
    end

    it 'renders the navigation buttons' do
      expect(response.body).to include('Previous')
      expect(response.body).to include('Next')
      expect(response.body).to include('Verify &amp; Next')
    end

    it 'renders the Regenerate Lesson button' do
      expect(response.body).to include('Regenerate Lesson')
    end

    it 'renders the Show more toggle' do
      expect(response.body).to include('Show more')
    end
  end
end
