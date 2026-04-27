# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/lessons/show', type: :view do
  let(:local_content_no_video) do
    ContentStudio::LocalContent.new(
      id: 1, lang: 'en', status: 'published', video_url: nil, video_published_at: nil
    )
  end

  let(:local_content_with_video) do
    ContentStudio::LocalContent.new(
      id: 2, lang: 'en', status: 'published',
      video_url: 'https://example-bucket.s3.amazonaws.com/lesson-1.mp4',
      video_published_at: nil
    )
  end

  let(:scenes) do
    [
      ContentStudio::Scene.new(id: 's1', timestamp: '0.00', narration: 'Scene one narration.', status: 'ready',
                               video_url: nil),
      ContentStudio::Scene.new(id: 's2', timestamp: '0.30', narration: 'Scene two narration.', status: 'ready',
                               video_url: nil)
    ]
  end

  let(:lesson) do
    ContentStudio::Lesson.new(
      id: 1,
      title: 'Introduction to Airport Services',
      description: 'This lesson introduces the core concepts of airport services management ' \
                   'including check-in procedures and passenger assistance.',
      duration: 1800,
      lesson_type: 'video',
      rating: 4.8,
      video_streaming_source: 'youtube',
      local_contents: [local_content_no_video],
      scenes: scenes
    )
  end

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:lesson, lesson)
    assign(:course_id, '1')
    assign(:prev_lesson_id, nil)
    assign(:next_lesson_id, '2')
  end

  it 'renders the Lesson Page heading' do
    render
    expect(rendered).to include('Lesson Page')
  end

  it 'renders the lesson title in the info panel' do
    render
    expect(rendered).to include('Introduction to Airport Services')
  end

  it 'renders the lesson description' do
    render
    expect(rendered).to include('check-in procedures and passenger assistance')
  end

  it 'renders the Show more toggle' do
    render
    expect(rendered).to include('Show more')
  end

  it 'renders the Previous navigation button' do
    render
    expect(rendered).to include('Previous')
  end

  it 'renders the Next navigation button' do
    render
    expect(rendered).to include('Next')
  end

  it 'renders the language from the first local content' do
    render
    expect(rendered).to include('En')
  end

  it 'renders the Script label' do
    render
    expect(rendered).to include('Script')
  end

  it 'renders a scene card for each scene' do
    render
    expect(rendered).to include('Scene 1')
    expect(rendered).to include('Scene 2')
  end

  it 'wires the scene-player Stimulus controller' do
    render
    expect(rendered).to include('data-controller="scene-player"')
  end

  it 'renders the scene player video target and placeholder' do
    render
    expect(rendered).to include('data-scene-player-target="video"')
    expect(rendered).to include('data-scene-player-target="placeholder"')
  end
end
