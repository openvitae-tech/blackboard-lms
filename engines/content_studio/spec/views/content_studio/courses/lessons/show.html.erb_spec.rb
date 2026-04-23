# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/lessons/show', type: :view do
  let(:local_content) do
    ContentStudio::LocalContent.new(
      id: 1, lang: 'en', status: 'published', video_url: nil, video_published_at: nil
    )
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
      local_contents: [local_content]
    )
  end

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:lesson, lesson)
    assign(:course_id, '1')
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

  it 'renders the Edit Video Style button' do
    render
    expect(rendered).to include('Edit Video Style')
  end

  it 'renders the Delete Lesson button' do
    render
    expect(rendered).to include('Delete Lesson')
  end

  it 'renders the Previous navigation button' do
    render
    expect(rendered).to include('Previous')
  end

  it 'renders the Next navigation button' do
    render
    expect(rendered).to include('Next')
  end

  it 'renders the Verify &amp; Next navigation button' do
    render
    expect(rendered).to include('Verify &amp; Next')
  end

  it 'renders the language dropdown with the current language' do
    render
    expect(rendered).to include('en')
  end

  it 'renders the Script textarea' do
    render
    expect(rendered).to include('Script')
  end

  it 'renders the Regenerate Lesson button' do
    render
    expect(rendered).to include('Regenerate Lesson')
  end

  it 'renders the video placeholder when no video URL is present' do
    render
    expect(rendered).to include('opacity-40')
    expect(rendered).not_to include('<video')
  end

  it 'renders a video element when a video URL is present' do
    local_content_with_video = ContentStudio::LocalContent.new(
      id: 1, lang: 'en', status: 'published',
      video_url: 'https://example-bucket.s3.amazonaws.com/lesson-1.mp4',
      video_published_at: nil
    )
    assign(:lesson, ContentStudio::Lesson.new(
                      id: 1,
                      title: 'Lesson with video',
                      description: 'Description.',
                      duration: 900,
                      lesson_type: 'video',
                      rating: 4.5,
                      video_streaming_source: nil,
                      local_contents: [local_content_with_video]
                    ))
    render
    expect(rendered).to include('<video')
    expect(rendered).to include('https://example-bucket.s3.amazonaws.com/lesson-1.mp4')
  end
end
