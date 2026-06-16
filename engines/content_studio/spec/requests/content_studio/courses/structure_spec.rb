# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Courses::Structure', type: :request do
  let(:structure) do
    ContentStudio::CourseStructure.new(
      id: 1, title: 'Test Course', duration: 3600,
      modules: [], verified_modules_count: 0, thumbnail_url: nil, saved: false
    )
  end

  describe 'GET /content_studio/courses/:id/structure' do
    context 'when the course exists' do
      before { allow(ContentStudio::ApiClient).to receive(:course_structure).and_return(structure) }

      it 'returns HTTP 200' do
        get '/content_studio/courses/1/structure'
        expect(response).to have_http_status(:ok)
      end
    end

    context 'when the course is not found' do
      before do
        allow(ContentStudio::ApiClient).to receive(:course_structure)
          .and_raise(Faraday::ResourceNotFound.new(nil))
      end

      it 'redirects to the content studio root' do
        get '/content_studio/courses/missing/structure'
        expect(response).to redirect_to('/content_studio/')
      end
    end
  end

  describe 'PATCH /content_studio/courses/:id/save' do
    context 'when save succeeds' do
      before { allow(ContentStudio::ApiClient).to receive(:save_course) }

      it 'redirects to the structure page' do
        patch '/content_studio/courses/1/save'
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a success flash notice' do
        patch '/content_studio/courses/1/save'
        expect(flash[:notice]).to eq('Course saved to LMS.')
      end
    end

    context 'when an error occurs' do
      before do
        allow(ContentStudio::ApiClient).to receive(:save_course).and_raise(Faraday::Error)
      end

      it 'redirects to the structure page' do
        patch '/content_studio/courses/1/save'
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets an alert flash message' do
        patch '/content_studio/courses/1/save'
        expect(flash[:alert]).to eq('Something went wrong while saving. Please try again.')
      end
    end
  end

  describe 'DELETE /content_studio/courses/:id' do
    context 'when the course is discarded successfully' do
      before { allow(ContentStudio::ApiClient).to receive(:discard_course) }

      it 'redirects to the content studio root' do
        delete '/content_studio/courses/1'
        expect(response).to redirect_to('/content_studio/')
      end
    end

    context 'when the course is locked' do
      before do
        allow(ContentStudio::ApiClient).to receive(:discard_course)
          .and_raise(Faraday::BadRequestError.new(nil))
      end

      it 'redirects back to the structure page' do
        delete '/content_studio/courses/1'
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a flash alert' do
        delete '/content_studio/courses/1'
        expect(flash[:alert]).to eq(I18n.t('content_studio.courses.discard.locked'))
      end
    end
  end
end
