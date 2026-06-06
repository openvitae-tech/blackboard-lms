# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'content_studio/courses/index', type: :view do
  let(:stats) do
    ContentStudio::CourseStats.new(created: 19, published: 6, in_progress: 7)
  end

  let(:sample_course) do
    ContentStudio::Course.new(
      id: 1,
      title: 'Front Desk Operations Excellence',
      duration: 7200,
      course_modules_count: 2,
      categories: ['Front Office', 'Hospitality'],
      banner: nil,
      rating: 4.7,
      visibility: 'public',
      levels: ['Beginner'],
      enrollments_count: 0,
      team_enrollments_count: 0,
      modules: []
    )
  end

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:stats, stats)
    assign(:in_progress, [sample_course])
    assign(:completed, [])
  end

  it 'renders the greeting' do
    render
    expect(rendered).to include('Hey Creator !')
  end

  it 'renders stats cards with labels and counts from the API' do
    render
    expect(rendered).to include("#{stats.created} Courses")
    expect(rendered).to include("#{stats.published} Courses")
    expect(rendered).to include("#{stats.in_progress} Courses")
    expect(rendered).to include('Created')
    expect(rendered).to include('Published')
    expect(rendered).to include('In Progress')
  end

  it 'renders the main action section' do
    render
    expect(rendered).to include('Transform Documents into engaging Courses')
    expect(rendered).to include('Create New')
  end

  it 'renders the Your Creations section with In Progress and Completed tabs' do
    render
    expect(rendered).to include('Your Creations')
    expect(rendered).to include('In Progress')
    expect(rendered).to include('Completed')
    expect(rendered).not_to include('No published courses yet.')
  end

  it 'renders a course card in the In Progress tab' do
    render
    expect(rendered).to include('Front Desk Operations Excellence')
  end

  it 'wraps each course card in a link to its structure page' do
    render
    expect(rendered).to include('href="/content_studio/courses/1/structure"')
  end

  context 'when the Completed tab has no courses' do
    before { assign(:completed, []) }

    it 'shows empty state for the Completed tab' do
      render
      expect(rendered).to include('No completed courses yet.')
    end
  end

  it 'renders the Show all Creations button' do
    render
    expect(rendered).to include('Show all Creations')
  end
end
