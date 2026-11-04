# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Microlessons::Structure', type: :request do
  describe 'GET /content_studio/microlessons/:id/structure' do
    context 'when the microlesson API returns full data' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_microlesson).and_return(
          'title' => 'Banking and Basic Strategies',
          'duration' => 120,
          'thumbnail_url' => nil,
          'micro_scenes' => [
            { 'title' => 'Scene One', 'narration' => 'Narration one.',
              'video_url' => 'https://example.com/scene1.mp4', 'thumbnail_url' => 'https://example.com/scene1.jpg',
              'status' => 'COMPLETED' },
            { 'title' => 'Scene Two', 'narration' => 'Narration two.',
              'video_url' => nil, 'thumbnail_url' => nil, 'status' => 'PENDING' }
          ]
        )
        get '/content_studio/microlessons/1/structure'
      end

      it 'returns HTTP 200' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders the microlesson title' do
        expect(response.body).to include('Banking and Basic Strategies')
      end

      it 'renders each scene title' do
        expect(response.body).to include('Scene One')
        expect(response.body).to include('Scene Two')
      end

      it 'renders the progress badge with the computed percentage' do
        expect(response.body).to include('Generation in Progress')
        expect(response.body).to include('50%')
      end

      it 'shows a generating indicator for the scene with no video yet' do
        expect(response.body).to include('Generating video')
      end

      it 'shows a preview/expand control for the scene whose video is ready' do
        expect(response.body).to include('Preview video')
      end
    end

    context 'when all scenes have generated video' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_microlesson).and_return(
          'title' => 'Banking and Basic Strategies',
          'micro_scenes' => [
            { 'title' => 'Scene One', 'narration' => 'Narration one.',
              'video_url' => 'https://example.com/scene1.mp4', 'status' => 'COMPLETED' }
          ]
        )
        get '/content_studio/microlessons/1/structure'
      end

      it 'hides the generation progress badge' do
        expect(response.body).not_to include('Generation in Progress')
      end

      it 'does not show a generating indicator' do
        expect(response.body).not_to include('Generating video')
      end
    end

    context 'when the microlesson API is unavailable' do
      before do
        allow(ContentStudio::ApiClient).to receive(:get_microlesson).and_raise(StandardError, 'boom')
        get '/content_studio/microlessons/1/structure'
      end

      it 'returns HTTP 200 using mock scene data' do
        expect(response).to have_http_status(:ok)
      end

      it 'renders the mock scene titles' do
        expect(response.body).to include('Setting the Scene')
        expect(response.body).to include('The Challenge Appears')
      end
    end
  end
end
