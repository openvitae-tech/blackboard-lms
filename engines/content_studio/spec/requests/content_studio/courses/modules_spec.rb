# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Courses::Modules', type: :request do
  describe 'DELETE /content_studio/courses/:course_id/modules/:id' do
    context 'when deletion succeeds' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_module)
        delete '/content_studio/courses/1/modules/m1'
      end

      it 'calls ApiClient.delete_module with the correct ids' do
        expect(ContentStudio::ApiClient).to have_received(:delete_module).with('m1', course_id: '1')
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a success flash notice' do
        expect(flash[:notice]).to eq('Module deleted successfully.')
      end
    end

    context 'when the module is locked' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_module).and_raise(Faraday::BadRequestError)
        delete '/content_studio/courses/1/modules/m1'
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a locked alert message' do
        expect(flash[:alert]).to eq('Module is currently being processed and cannot be deleted.')
      end
    end

    context 'when the module is not found' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_module).and_raise(Faraday::ResourceNotFound)
        delete '/content_studio/courses/1/modules/m1'
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a not found alert message' do
        expect(flash[:alert]).to eq('Module not found.')
      end
    end

    context 'when an unexpected error occurs' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_module).and_raise(Faraday::Error)
        delete '/content_studio/courses/1/modules/m1'
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a generic error alert message' do
        expect(flash[:alert]).to eq('Something went wrong. Please try again.')
      end
    end
  end

  describe 'DELETE /content_studio/courses/:course_id/modules/:module_id/lessons' do
    context 'when deletion succeeds' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_lesson)
        delete '/content_studio/courses/1/modules/m1/lessons', params: { lesson_ids: %w[l1 l2] }
      end

      it 'calls ApiClient.delete_lesson for each selected lesson' do
        expect(ContentStudio::ApiClient).to have_received(:delete_lesson).with('l1', course_id: '1')
        expect(ContentStudio::ApiClient).to have_received(:delete_lesson).with('l2', course_id: '1')
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a success flash notice' do
        expect(flash[:notice]).to eq('Selected lessons deleted successfully.')
      end
    end

    context 'when the course is locked' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_lesson).and_raise(Faraday::BadRequestError)
        delete '/content_studio/courses/1/modules/m1/lessons', params: { lesson_ids: ['l1'] }
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a locked alert message' do
        expect(flash[:alert]).to eq('Course is currently being processed. Please wait before deleting.')
      end
    end

    context 'when a lesson is not found' do
      before do
        allow(ContentStudio::ApiClient).to receive(:delete_lesson).and_raise(Faraday::ResourceNotFound)
        delete '/content_studio/courses/1/modules/m1/lessons', params: { lesson_ids: ['l1'] }
      end

      it 'redirects to the course structure page' do
        expect(response).to redirect_to('/content_studio/courses/1/structure')
      end

      it 'sets a not found alert message' do
        expect(flash[:alert]).to eq('One or more lessons not found.')
      end
    end
  end
end
