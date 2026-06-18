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
      modules: [],
      created_at: '2025-06-10T10:00:00Z'
    )
  end

  let(:sample_kit) do
    ContentStudio::Kit.new(
      id: 'kit-1',
      title: 'Banking Basics',
      status: 'IN_PROGRESS',
      stage: nil,
      thumbnail_url: nil,
      doc_count: 3,
      created_at: '2025-06-17T12:00:00Z',
      updated_at: nil,
      expires_at: nil,
      components: []
    )
  end

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:stats, stats)
    assign(:in_progress_creations, [sample_kit, sample_course])
    assign(:completed_creations, [])
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
    expect(rendered).to include('Transform documents into engaging courses & classroom kits')
    expect(rendered).to include('Create new')
  end

  it 'renders the Recent Creations section with In Progress and Completed tabs' do
    render
    expect(rendered).to include('Recent Creations')
    expect(rendered).to include('In Progress')
    expect(rendered).to include('Completed')
  end

  it 'renders a course card in the In Progress tab' do
    render
    expect(rendered).to include('Front Desk Operations Excellence')
  end

  it 'wraps each course card in a link to its structure page' do
    render
    expect(rendered).to include('href="/content_studio/courses/1/structure"')
  end

  it 'renders a kit card in the In Progress tab' do
    render
    expect(rendered).to include('Banking Basics')
  end

  it 'wraps each kit card in a link to its structure page' do
    render
    expect(rendered).to include('href="/content_studio/classroom-kits/kit-1/structure"')
  end

  it 'renders the Course type tag on course cards' do
    render
    expect(rendered).to include('Course')
  end

  it 'renders the Classroom Kit type tag on kit cards' do
    render
    expect(rendered).to include('Classroom Kit')
  end

  context 'when the Completed tab has no creations' do
    before { assign(:completed_creations, []) }

    it 'shows empty state for the Completed tab' do
      render
      expect(rendered).to include('No completed creations yet.')
    end
  end

  context 'when there are no in-progress creations' do
    before { assign(:in_progress_creations, []) }

    it 'shows empty state for the In Progress tab' do
      render
      expect(rendered).to include('No creations in progress.')
    end
  end

  it 'renders the Create new button' do
    render
    expect(rendered).to include('Create new')
  end
end
