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
end
