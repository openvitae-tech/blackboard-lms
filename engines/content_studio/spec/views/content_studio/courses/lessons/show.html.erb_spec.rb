# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/lessons/show', type: :view do
  let(:scenes) do
    [
      ContentStudio::Scene.new(id: 's1', duration: 90, narration: 'Scene one narration.', status: 'APPROVED',
                               video_url: nil),
      ContentStudio::Scene.new(id: 's2', duration: nil, narration: 'Scene two narration.', status: 'APPROVED',
                               video_url: nil)
    ]
  end

  let(:lesson) do
    ContentStudio::StructureLesson.new(
      id: '1',
      title: 'Introduction to Airport Services',
      description: 'This lesson introduces the core concepts of airport services management ' \
                   'including check-in procedures and passenger assistance.',
      estimated_duration: 1800,
      status: 'PENDING',
      video_url: nil,
      verified: false,
      scenes: scenes
    )
  end

  before do
    view.singleton_class.define_method(:alert_modal_path) { |**_| '/alert_modal' }
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

  it 'renders the language selector' do
    render
    expect(rendered).to include('English')
  end

  it 'renders the Script label' do
    render
    expect(rendered).to include('Script')
  end

  it 'renders the menu component trigger button' do
    render
    expect(rendered).to include('data-controller="menu-component"')
  end

  it 'renders the Delete Lesson menu item pointing to the alert modal' do
    render
    expect(rendered).to include('Delete Lesson')
    expect(rendered).to include('alert_modal')
  end

  it 'renders the Download Lesson menu item linking to the download path' do
    render
    expect(rendered).to include('Download Lesson')
    expect(rendered).to include('download')
  end

  it 'renders a scene card for each scene' do
    render
    expect(rendered).to include('Scene 1')
    expect(rendered).to include('Scene 2')
  end

  it 'renders the formatted duration for a scene with duration' do
    render
    expect(rendered).to include('1.30')
  end

  it 'renders 0.00 for a scene with no duration' do
    render
    expect(rendered).to include('0.00')
  end

  describe '#format_scene_duration' do
    let(:obj) { Object.new.extend(ContentStudio::ApplicationHelper) }

    it 'returns 0.00 for nil' do
      expect(obj.format_scene_duration(nil)).to eq('0.00')
    end

    it 'returns 0.00 for zero' do
      expect(obj.format_scene_duration(0)).to eq('0.00')
    end

    it 'formats seconds under a minute' do
      expect(obj.format_scene_duration(45)).to eq('0.45')
    end

    it 'formats exactly one minute' do
      expect(obj.format_scene_duration(60)).to eq('1.00')
    end

    it 'formats minutes and seconds' do
      expect(obj.format_scene_duration(90)).to eq('1.30')
    end

    it 'zero-pads single-digit seconds' do
      expect(obj.format_scene_duration(65)).to eq('1.05')
    end

    it 'truncates float seconds to integer' do
      expect(obj.format_scene_duration(90.9)).to eq('1.30')
    end
  end

  it 'renders video_film.gif for scenes that are not completed' do
    render
    expect(rendered).to match(/src="[^"]*video_film[^"]*\.gif"/)
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

  it 'renders the Regenerate Scene button' do
    render
    expect(rendered).to include('Regenerate Scene')
  end

  it 'wires the Regenerate Scene button to the scene-player controller' do
    render
    expect(rendered).to include('scene-player#regenerate')
    expect(rendered).to include('data-scene-player-target="regenerateButton"')
  end

  it 'renders scene items with scene id, status, and regenerate url data attributes' do
    render
    expect(rendered).to include('data-scene-id="s1"')
    expect(rendered).to include('data-scene-status="APPROVED"')
    expect(rendered).to include('data-regenerate-url=')
  end

  it 'renders the script textarea with a 512 character limit' do
    render
    expect(rendered).to include('maxlength="512"')
  end

  it 'renders the Maximum 512 characters support text' do
    render
    expect(rendered).to include('Maximum 512 characters')
  end

  it 'wires the textarea input event to the scene-player controller' do
    render
    expect(rendered).to include('scene-player#onNarrationInput')
  end

  it 'renders play and pause icon targets in the control bar' do
    render
    expect(rendered).to include('data-scene-player-target="playIcon"')
    expect(rendered).to include('data-scene-player-target="pauseIcon"')
  end

  it 'renders prev and next scene navigation buttons' do
    render
    expect(rendered).to include('scene-player#prev')
    expect(rendered).to include('scene-player#next')
  end

  it 'wires the play/pause toggle to the scene-player controller' do
    render
    expect(rendered).to include('scene-player#togglePlay')
  end

  it 'renders the control bar with hover visibility class' do
    render
    expect(rendered).to include('group-hover:opacity-100')
  end

  context 'when the lesson has no scenes' do
    before do
      assign(:lesson, ContentStudio::StructureLesson.new(
                        id: '1',
                        title: 'Introduction to Airport Services',
                        description: 'Desc',
                        estimated_duration: 1800,
                        status: 'WAITING',
                        video_url: nil,
                        verified: false,
                        scenes: []
                      ))
    end

    it 'does not render the video player' do
      render
      expect(rendered).not_to include('data-scene-player-target="video"')
    end

    it 'does not render the Script label or textarea' do
      render
      expect(rendered).not_to include('Script')
      expect(rendered).not_to include('scene-player#onNarrationInput')
    end

    it 'does not render the Regenerate Scene button' do
      render
      expect(rendered).not_to include('Regenerate Scene')
    end

    it 'renders the empty state message' do
      render
      expect(rendered).to include('No scenes have been generated for this lesson yet')
    end

    it 'renders the Delete Lesson button' do
      render
      expect(rendered).to include('Delete Lesson')
    end

    it 'renders the Regenerate Lesson button' do
      render
      expect(rendered).to include('Regenerate Lesson')
    end

    it 'renders the delete form pointing to the destroy route' do
      render
      expect(rendered).to include('action="/content_studio/courses/1/lessons/1"')
    end

    it 'renders the regenerate form pointing to the regenerate route' do
      render
      expect(rendered).to include('action="/content_studio/courses/1/lessons/1/regenerate"')
    end
  end

  context 'when lesson status is VIDEO_READY' do
    let(:lesson) do
      ContentStudio::StructureLesson.new(
        id: '1', title: 'Introduction to Airport Services',
        description: 'Desc', estimated_duration: 1800,
        status: 'VIDEO_READY', video_url: nil, verified: false, scenes: scenes
      )
    end

    it 'renders the Verify & Next button' do
      render
      expect(rendered).to include('Verify &amp; Next')
    end

    it 'renders the verify form targeting _top turbo frame' do
      render
      expect(rendered).to include('data-turbo-frame="_top"')
    end
  end

  context 'when lesson status is VERIFIED' do
    let(:lesson) do
      ContentStudio::StructureLesson.new(
        id: '1', title: 'Introduction to Airport Services',
        description: 'Desc', estimated_duration: 1800,
        status: 'VERIFIED', video_url: 'https://example.com/lesson.mp4', verified: true, scenes: scenes
      )
    end

    it 'renders the verified icon and text' do
      render
      expect(rendered).to include('text-secondary')
      expect(rendered).to include('Verified')
    end

    it 'does not render the Verify & Next form' do
      render
      expect(rendered).not_to include('Verify &amp; Next')
    end
  end
end
