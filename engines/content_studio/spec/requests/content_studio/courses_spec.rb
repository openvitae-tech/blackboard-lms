# frozen_string_literal: true

require_relative '../../rails_helper'

RSpec.describe 'ContentStudio::Courses', type: :request do
  let(:stats) { ContentStudio::CourseStats.new(created: 10, published: 5, in_progress: 3) }

  let(:course) do
    ContentStudio::Course.new(
      id: 1,
      title: 'Front Desk Operations Excellence',
      duration: 7200,
      course_modules_count: 2,
      categories: ['Front Office', 'Hospitality'],
      banner: nil,
      rating: nil,
      is_published: false,
      visibility: 'public',
      levels: ['Beginner'],
      enrollments_count: 0,
      team_enrollments_count: 0,
      modules: [],
      progress: 45
    )
  end

  let(:published_course) do
    ContentStudio::Course.new(
      id: 7,
      title: 'Food & Beverage Service Fundamentals',
      duration: 9000,
      course_modules_count: 2,
      categories: ['Food & Beverage'],
      banner: nil,
      rating: 4.5,
      is_published: true,
      visibility: 'public',
      levels: ['Beginner'],
      enrollments_count: 185,
      team_enrollments_count: 8,
      modules: [],
      progress: nil
    )
  end

  before do
    allow(ContentStudio::ApiClient).to receive(:course_stats).and_return(stats)
    allow(ContentStudio::ApiClient).to receive(:list_courses_by_status).with('to_be_verified').and_return([course])
    allow(ContentStudio::ApiClient).to receive(:list_courses_by_status).with('verified').and_return([])
    allow(ContentStudio::ApiClient).to receive(:list_courses_by_status).with('published').and_return([published_course])
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
      expect(response.body).to include('Transform Documents into engaging Courses')
      expect(response.body).to include('Create New Course')
    end

    it 'renders all three tab headers' do
      expect(response.body).to include('To be Verified')
      expect(response.body).to include('Verified')
      expect(response.body).to include('Published')
    end

    it 'renders course cards in the to_be_verified tab' do
      expect(response.body).to include('Front Desk Operations Excellence')
      expect(response.body).to include('Pending')
    end

    it 'renders course cards in the published tab' do
      expect(response.body).to include('Food &amp; Beverage Service Fundamentals')
      expect(response.body).to include('Published')
    end

    it 'shows empty state for the verified tab' do
      expect(response.body).to include('No verified courses yet.')
    end

    it 'renders the Show all Creations button' do
      expect(response.body).to include('Show all Creations')
    end
  end
end
