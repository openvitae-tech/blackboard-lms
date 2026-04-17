# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'ContentStudio::Courses::Wizard', type: :request do
  let(:metadata) do
    ContentStudio::CourseMetadata.new(
      categories: ['Housekeeping', 'F&B'],
      languages: %w[English Malayalam]
    )
  end

  before do
    allow(ContentStudio::ApiClient).to receive(:course_metadata).and_return(metadata)
  end

  describe 'GET /content_studio/courses/new' do
    before { get '/content_studio/courses/new' }

    it 'returns HTTP 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the wizard steps' do
      expect(response.body).to include('Upload doc')
      expect(response.body).to include('Configure Video')
      expect(response.body).to include('Course Structure')
    end

    it 'renders the file upload card' do
      expect(response.body).to include('Choose Course Documents')
      expect(response.body).to include('File types : pdf, png, jpeg, doc')
    end

    it 'renders the metadata form fields' do
      expect(response.body).to include('Course Level')
      expect(response.body).to include('Course Category')
      expect(response.body).to include('Languages')
      expect(response.body).to include('Special Instructions if any')
    end

    it 'renders category options from metadata' do
      expect(response.body).to include('Housekeeping')
      expect(response.body).to include('F&amp;B')
    end

    it 'renders language options from metadata' do
      expect(response.body).to include('English')
      expect(response.body).to include('Malayalam')
    end

    it 'renders the footer buttons' do
      expect(response.body).to include('Cancel')
      expect(response.body).to include('Next : Configure Video Style')
    end
  end

  describe 'POST /content_studio/courses' do
    it 'redirects after submission' do
      post '/content_studio/courses'
      expect(response).to have_http_status(:redirect)
    end
  end
end
