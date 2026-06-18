# frozen_string_literal: true

require_relative '../../rails_helper'

RSpec.describe 'ContentStudio::Courses', type: :request do
  let(:stats) { ContentStudio::CourseStats.new(created: 10, published: 5, in_progress: 3) }

  let(:in_progress_course) do
    ContentStudio::Course.new(
      id: 1,
      title: 'Front Desk Operations Excellence',
      duration: 7200,
      course_modules_count: 2,
      categories: ['Front Office', 'Hospitality'],
      banner: nil,
      rating: nil,
      visibility: 'public',
      levels: ['Beginner'],
      enrollments_count: 0,
      team_enrollments_count: 0,
      modules: [],
      progress: 45
    )
  end

  before do
    allow(ContentStudio::ApiClient).to receive_messages(
      course_stats: stats,
      list_classroom_kits_by_status: []
    )
    allow(ContentStudio::ApiClient).to receive(:list_courses_by_status)
      .with('in_progress').and_return([in_progress_course])
    allow(ContentStudio::ApiClient).to receive(:list_courses_by_status).with('completed').and_return([])
  end

  describe 'GET /content_studio' do
    before { get '/content_studio' }

    it 'returns HTTP 200' do
      expect(response).to have_http_status(:ok)
    end

    it 'renders the stats section with counts' do
      expect(response.body).to include("#{stats.created} Courses")
      expect(response.body).to include("#{stats.published} Courses")
      expect(response.body).to include("#{stats.in_progress} Courses")
    end

    it 'renders the main action section with CTA' do
      expect(response.body).to include('Transform documents into engaging courses & classroom kits')
      expect(response.body).to include('Create new')
    end

    it 'renders In Progress and Completed tab headers' do
      expect(response.body).to include('In Progress')
      expect(response.body).to include('Completed')
      expect(response.body).not_to include('No published courses yet.')
    end

    it 'renders course cards in the In Progress tab' do
      expect(response.body).to include('Front Desk Operations Excellence')
    end

    it 'shows empty state for the Completed tab' do
      expect(response.body).to include('No completed creations yet.')
    end

    it 'does not render a Show all Creations button' do
      expect(response.body).not_to include('Show all Creations')
    end
  end
end
