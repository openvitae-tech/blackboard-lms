# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Courses::Wizard', type: :request do
  describe 'GET /content_studio/courses/new' do
    before do
      allow(ContentStudio::ApiClient).to receive(:course_metadata).and_return(
        ContentStudio::CourseMetadata.new(categories: [], languages: [])
      )
    end

    it 'returns HTTP 200' do
      get '/content_studio/courses/new'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /content_studio/courses' do
    it 'redirects after submission' do
      post '/content_studio/courses'
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET /content_studio/courses/:id/configure_video' do
    it 'returns HTTP 200' do
      get '/content_studio/courses/1/configure_video'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /content_studio/courses/:id/configure_video' do
    it 'redirects after submission' do
      patch '/content_studio/courses/1/configure_video'
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'GET /content_studio/courses/:id/generating' do
    it 'returns HTTP 200' do
      get '/content_studio/courses/1/generating'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /content_studio/courses/:id/generation_status' do
    before do
      allow(ContentStudio::ApiClient).to receive(:generation_status).and_return(
        ContentStudio::GenerationStatus.new(status: 'pending', redirect_url: nil)
      )
    end

    it 'returns HTTP 200 with JSON' do
      get '/content_studio/courses/1/generation_status'
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to include('application/json')
    end

    it 'includes status in the response body' do
      get '/content_studio/courses/1/generation_status'
      body = JSON.parse(response.body)
      expect(body['status']).to eq('pending')
    end
  end
end
