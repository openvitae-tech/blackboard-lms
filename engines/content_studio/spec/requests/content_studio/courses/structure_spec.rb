# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Courses::Structure', type: :request do
  let(:structure) do
    ContentStudio::CourseStructure.new(
      id: 1, title: 'Test Course', duration: 3600,
      modules: [], verified_modules_count: 0, thumbnail_url: nil
    )
  end

  describe 'GET /content_studio/courses/:id/structure' do
    before { allow(ContentStudio::ApiClient).to receive(:course_structure).and_return(structure) }

    it 'returns HTTP 200' do
      get '/content_studio/courses/1/structure'
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /content_studio/courses/:id/save' do
    before { allow(ContentStudio::ApiClient).to receive(:save_course) }

    it 'redirects after save' do
      patch '/content_studio/courses/1/save'
      expect(response).to have_http_status(:redirect)
    end
  end

  describe 'DELETE /content_studio/courses/:id' do
    before { allow(ContentStudio::ApiClient).to receive(:discard_course) }

    it 'redirects after discard' do
      delete '/content_studio/courses/1'
      expect(response).to have_http_status(:redirect)
    end
  end
end
