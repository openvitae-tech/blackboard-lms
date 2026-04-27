# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/structure/show', type: :view do
  let(:airport_services_module) do
    ContentStudio::StructureModule.new(
      id: 1, title: 'Airport Services',
      lessons: [
        ContentStudio::StructureLesson.new(id: 1, title: 'Introduction', status: 'verified', scenes: []),
        ContentStudio::StructureLesson.new(id: 2, title: 'Rules and regulations', status: 'video_ready', scenes: [])
      ]
    )
  end

  let(:wine_serving_module) do
    ContentStudio::StructureModule.new(
      id: 2, title: 'Wine Serving',
      lessons: [
        ContentStudio::StructureLesson.new(id: 3, title: 'Lesson name', status: 'in_process', scenes: [])
      ]
    )
  end

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:structure, ContentStudio::CourseStructure.new(
                         id: 1,
                         title: 'Airport Services Management',
                         duration: 9240,
                         modules: [airport_services_module, wine_serving_module],
                         verified_modules_count: 1,
                         thumbnail_url: nil
                       ))
  end

  it 'renders Course Structure as the active wizard step' do
    render
    expect(rendered).to include('Course Structure')
  end

  it 'renders the Course Overview panel' do
    render
    expect(rendered).to include('Course Overview')
  end

  it 'renders each module title' do
    render
    expect(rendered).to include('Airport Services')
    expect(rendered).to include('Wine Serving')
  end

  it 'renders lesson titles' do
    render
    expect(rendered).to include('Introduction')
    expect(rendered).to include('Rules and regulations')
  end

  it 'renders lesson status chips' do
    render
    expect(rendered).to include('Verified')
    expect(rendered).to include('Video ready')
    expect(rendered).to include('In Process')
  end

  it 'renders course name in sidebar' do
    render
    expect(rendered).to include('Airport Services Management')
  end

  it 'wires the collapsible-group Stimulus controller' do
    render
    expect(rendered).to include('collapsible-group')
  end

  it 'wires the collapsible Stimulus controller on module cards' do
    render
    expect(rendered).to include('data-controller="collapsible"')
  end

  it 'wires the lesson-name Stimulus controller on each lesson pill' do
    render
    expect(rendered).to include('data-controller="lesson-name"')
  end

  it 'sets the href value to the lesson show path on each lesson pill' do
    render
    expect(rendered).to include('data-lesson-name-href-value="/content_studio/courses/1/lessons/1"')
    expect(rendered).to include('data-lesson-name-href-value="/content_studio/courses/1/lessons/2"')
  end

  it 'renders the inline edit input alongside each lesson title' do
    render
    expect(rendered).to include('data-lesson-name-target="input"')
  end

  context 'when thumbnail_url is present' do
    before do
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1,
                           title: 'Airport Services Management',
                           duration: 9240,
                           modules: [airport_services_module],
                           verified_modules_count: 1,
                           thumbnail_url: 'https://example.com/thumb.jpg'
                         ))
    end

    it 'renders the thumbnail image' do
      render
      expect(rendered).to include('https://example.com/thumb.jpg')
    end
  end

  context 'when thumbnail_url is absent' do
    it 'renders the placeholder image in the thumbnail section' do
      render
      expect(rendered).to include('/placeholder.gif')
    end
  end
end
