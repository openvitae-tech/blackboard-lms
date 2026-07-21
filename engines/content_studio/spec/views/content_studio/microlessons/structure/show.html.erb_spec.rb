# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/microlessons/structure/show', type: :view do
  let(:scenes) do
    [
      { number: 1, total: 2, title: 'Setting the Scene', narration: 'Narration one.',
        video_url: 'https://example.com/scene1.mp4', thumbnail_url: 'https://example.com/scene1.jpg',
        status: 'COMPLETED' },
      { number: 2, total: 2, title: 'The Challenge Appears', narration: 'Narration two.',
        video_url: nil, thumbnail_url: nil, status: 'PENDING' }
    ]
  end

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:microlesson_id, '1')
    assign(:title, 'Banking and Basic Strategies')
    assign(:duration_seconds, 120)
    assign(:thumbnail_url, nil)
    assign(:scenes, scenes)
    assign(:percent_complete, 50)
  end

  it 'renders the microlesson title in the header and summary card' do
    render
    expect(rendered).to include('Banking and Basic Strategies')
  end

  it 'renders the structure-polling and scene-player Stimulus controllers' do
    render
    expect(rendered).to include('structure-polling scene-player')
  end

  it 'renders a scene card for each scene' do
    render
    expect(rendered).to include('Setting the Scene')
    expect(rendered).to include('The Challenge Appears')
  end

  it 'wires each scene card to the scene-player controller' do
    render
    expect(rendered).to include('data-scene-player-target="item"')
    expect(rendered).to include('scene-player#select')
  end

  it 'shows a generating indicator for scenes with no video yet' do
    render
    expect(rendered).to include('Generating video')
  end

  it 'shows a preview/expand control for scenes whose video has finished generating' do
    render
    expect(rendered).to include('Preview video')
    expect(rendered).to include('https://example.com/scene1.jpg')
  end

  it 'renders the Microlesson summary panel' do
    render
    expect(rendered).to include('Microlesson summary')
  end

  it 'renders the static language selector' do
    render
    expect(rendered).to include('English')
  end

  it 'renders Discard and Save buttons' do
    render
    expect(rendered).to include('Discard')
    expect(rendered).to include('Save')
  end

  it 'renders the generation progress badge while incomplete' do
    render
    expect(rendered).to include('Generation in Progress')
    expect(rendered).to include('50%')
  end

  context 'when generation is complete' do
    before { assign(:percent_complete, 100) }

    it 'hides the generation progress badge' do
      render
      expect(rendered).not_to include('Generation in Progress')
    end
  end
end
