# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/structure/show', type: :view do
  let(:airport_services_module) do
    ContentStudio::StructureModule.new(
      id: 1, title: 'Airport Services',
      lessons: [
        ContentStudio::StructureLesson.new(id: 1, title: 'Introduction', status: 'VERIFIED', scenes: []),
        ContentStudio::StructureLesson.new(id: 2, title: 'Rules and regulations', status: 'VIDEO_READY', scenes: [])
      ]
    )
  end

  let(:wine_serving_module) do
    ContentStudio::StructureModule.new(
      id: 2, title: 'Wine Serving',
      lessons: [
        ContentStudio::StructureLesson.new(id: 3, title: 'Lesson name', status: 'PENDING', scenes: [])
      ]
    )
  end

  before do
    view.singleton_class.define_method(:alert_modal_path) { |**_| '/alert_modal' }
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:structure, ContentStudio::CourseStructure.new(
                         id: 1,
                         title: 'Airport Services Management',
                         duration: 9240,
                         modules: [airport_services_module, wine_serving_module],
                         verified_modules_count: 1,
                         thumbnail_url: nil, saved: false
                       ))
  end

  it 'renders the structure-polling Stimulus controller' do
    render
    expect(rendered).to include('structure-polling')
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

  context 'when script writer has completed and a lesson has no scenes' do
    before do
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1,
                           title: 'Airport Services Management',
                           duration: 9240,
                           modules: [airport_services_module, wine_serving_module],
                           verified_modules_count: 1,
                           thumbnail_url: nil, saved: false,
                           stage: 'scene_writer_completed'
                         ))
    end

    it 'renders the exclamation icon' do
      render
      expect(rendered).to include('w-6 h-6 text-danger flex-shrink-0')
    end
  end

  context 'when script writer has not yet completed and a lesson has no scenes' do
    it 'does not render the exclamation icon' do
      render
      expect(rendered).not_to include('w-6 h-6 text-danger flex-shrink-0')
    end
  end

  context 'when lessons have scenes' do
    let(:scene) do
      ContentStudio::Scene.new(id: 1, timestamp: nil, visual: nil, narration: 'test',
                               status: 'COMPLETED', video_url: 'https://example.com/v.mp4', thumbnail_url: nil)
    end

    before do
      mod = ContentStudio::StructureModule.new(
        id: 1, title: 'Airport Services',
        lessons: [
          ContentStudio::StructureLesson.new(id: 1, title: 'Introduction', status: 'VERIFIED', scenes: [scene]),
          ContentStudio::StructureLesson.new(id: 2, title: 'Rules and regulations', status: 'VIDEO_READY',
                                             scenes: [scene]),
          ContentStudio::StructureLesson.new(id: 3, title: 'Lesson name', status: 'PENDING', scenes: [scene])
        ]
      )
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1, title: 'Airport Services Management', duration: 9240,
                           modules: [mod], verified_modules_count: 1, thumbnail_url: nil, saved: false
                         ))
    end

    it 'renders lesson status icons' do
      render
      expect(rendered).to include('w-6 h-6 text-secondary flex-shrink-0')
      expect(rendered).to include('w-6 h-6 text-primary flex-shrink-0')
      expect(rendered).to include('animate-spin')
    end
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

  context 'when all scenes in a module have a video_url' do
    let(:ready_scene) do
      ContentStudio::Scene.new(id: 's1', status: 'COMPLETED',
                               video_url: 'https://example.com/v.mp4', thumbnail_url: nil)
    end

    let(:ready_module) do
      ContentStudio::StructureModule.new(
        id: 3, title: 'Ready Module',
        lessons: [
          ContentStudio::StructureLesson.new(id: 4, title: 'Ready Lesson', status: 'VIDEO_READY',
                                             video_url: nil, verified: false, scenes: [ready_scene]),
          ContentStudio::StructureLesson.new(id: 5, title: 'Another Lesson', status: 'VIDEO_READY',
                                             video_url: nil, verified: false, scenes: [ready_scene])
        ]
      )
    end

    before do
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1, title: 'Airport Services Management', duration: 9240,
                           modules: [ready_module], verified_modules_count: 0, thumbnail_url: nil, saved: false
                         ))
    end

    it 'renders the Select link' do
      render
      expect(rendered).to include('data-module-select-target="selectLink"')
      expect(rendered).to include('Select')
    end

    it 'wires the module-select Stimulus controller' do
      render
      expect(rendered).to include('module-select')
    end

    it 'renders lesson checkboxes' do
      render
      expect(rendered).to include('data-module-select-target="lessonCheckbox"')
    end

    it 'renders the delete bar' do
      render
      expect(rendered).to include('data-module-select-target="deleteBar"')
    end

    it 'renders the modal trigger link' do
      render
      expect(rendered).to include('data-module-select-target="modalTrigger"')
    end

    it 'renders the delete module path as a data value' do
      render
      expect(rendered).to include('data-module-select-delete-module-path-value=')
      expect(rendered).to include('/content_studio/courses/1/modules/3')
    end

    it 'renders lesson rows as draggable with reorder paths' do
      render
      expect(rendered).to include('data-module-select-target="lessonRow"')
      expect(rendered).to include('draggable="true"')
      expect(rendered).to include('/content_studio/courses/1/lessons/4/reorder')
      expect(rendered).to include('/content_studio/courses/1/lessons/5/reorder')
    end
  end

  context 'when not all scenes in a module have a video_url' do
    it 'does not render the Select link' do
      render
      expect(rendered).not_to include('data-module-select-target="selectLink"')
    end

    it 'does not wire the module-select controller' do
      render
      expect(rendered).not_to include('module-select')
    end
  end

  it 'renders a hidden Expand link as a collapsible expandLink target on each module card' do
    render
    expect(rendered).to include('data-collapsible-target="expandLink"')
    expect(rendered).to include('collapsible#expand')
    expect(rendered).to include('Expand')
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
                           thumbnail_url: 'https://example.com/thumb.jpg', saved: false
                         ))
    end

    it 'renders the thumbnail image' do
      render
      expect(rendered).to include('https://example.com/thumb.jpg')
    end

    it 'passes the thumbnail URL as a Stimulus value on the polling controller' do
      render
      expect(rendered).to include('data-structure-polling-thumbnail-url-value="https://example.com/thumb.jpg"')
    end
  end

  context 'when thumbnail_url is absent' do
    it 'renders the image-ai gif as fallback in the thumbnail section' do
      render
      expect(rendered).to match(/src="[^"]*image-ai[^"]*\.gif"/)
    end

    it 'passes a blank thumbnail URL value on the polling controller' do
      render
      expect(rendered).to include('data-structure-polling-thumbnail-url-value=""')
    end
  end

  context 'when there are pending lessons' do
    it 'renders the status card below the stepper' do
      render
      expect(rendered).to include('border-secondary-dark')
      expect(rendered).to include('Generating your course')
    end

    it 'renders the animated progress bar in the status card' do
      render
      expect(rendered).to include('progressbar-animated')
    end
  end

  context 'when progress_text is present and no pending lessons' do
    before do
      all_verified = ContentStudio::StructureModule.new(
        id: 1, title: 'Airport Services',
        lessons: [
          ContentStudio::StructureLesson.new(id: 1, title: 'Introduction', status: 'VERIFIED', scenes: [])
        ]
      )
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1, title: 'Airport Services Management', duration: 9240,
                           modules: [all_verified], verified_modules_count: 1, thumbnail_url: nil, saved: false,
                           progress_text: 'Generating module 2 of 3'
                         ))
    end

    it 'renders the status card with the progress text' do
      render
      expect(rendered).to include('border-secondary-dark')
      expect(rendered).to include('Generating module 2 of 3')
    end
  end

  context 'when the course is not yet saved to LMS' do
    it 'renders the Save Course button' do
      render
      expect(rendered).to include('Save Course')
      expect(rendered).not_to include('Update Course')
    end
  end

  context 'when the course is already saved to LMS' do
    before do
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1,
                           title: 'Airport Services Management',
                           duration: 9240,
                           modules: [airport_services_module, wine_serving_module],
                           verified_modules_count: 1,
                           thumbnail_url: nil, saved: true
                         ))
    end

    it 'renders the Update Course button' do
      render
      expect(rendered).to include('Update Course')
      expect(rendered).not_to include('Save Course')
    end
  end

  it 'renders the Discard Course button' do
    render
    expect(rendered).to include('Discard Course')
  end

  it 'renders the Discard Course button as a modal link to the alert_modal' do
    render
    expect(rendered).to include('/alert_modal')
    expect(rendered).to include('data-turbo-frame="modal"')
  end

  it 'renders the save form targeting the save route' do
    render
    expect(rendered).to include('action="/content_studio/courses/1/save"')
  end

  context 'when modules are blank (early generation, no lessons yet)' do
    before do
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1, title: 'Airport Services Management', duration: 0,
                           modules: [], verified_modules_count: 0,
                           thumbnail_url: nil, saved: false, progress_text: 'Preparing your course…'
                         ))
    end

    it 'still renders the progress card' do
      render
      expect(rendered).to include('border-secondary-dark')
      expect(rendered).to include('Preparing your course')
    end
  end

  context 'when all lessons have a video_url (course complete)' do
    before do
      completed_module = ContentStudio::StructureModule.new(
        id: 1, title: 'Airport Services',
        lessons: [
          ContentStudio::StructureLesson.new(id: 1, title: 'Introduction', status: 'VERIFIED',
                                             video_url: 'https://example.com/v1.mp4', scenes: []),
          ContentStudio::StructureLesson.new(id: 2, title: 'Rules', status: 'VIDEO_READY',
                                             video_url: 'https://example.com/v2.mp4', scenes: [])
        ]
      )
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1, title: 'Airport Services Management', duration: 9240,
                           modules: [completed_module], verified_modules_count: 1,
                           thumbnail_url: nil, saved: false, progress_text: 'Course is ready!'
                         ))
    end

    it 'does not render the progress card even when progress_text is present' do
      render
      expect(rendered).not_to include('border-secondary-dark')
      expect(rendered).not_to include('Course is ready!')
    end
  end

  context 'when no pending lessons and no progress_text' do
    before do
      all_verified = ContentStudio::StructureModule.new(
        id: 1, title: 'Airport Services',
        lessons: [
          ContentStudio::StructureLesson.new(id: 1, title: 'Introduction', status: 'VERIFIED', scenes: [])
        ]
      )
      assign(:structure, ContentStudio::CourseStructure.new(
                           id: 1, title: 'Airport Services Management', duration: 9240,
                           modules: [all_verified], verified_modules_count: 1, thumbnail_url: nil, saved: false
                         ))
    end

    it 'does not render the status card' do
      render
      expect(rendered).not_to include('border-secondary-dark')
      expect(rendered).not_to include('progressbar-animated')
    end
  end
end
