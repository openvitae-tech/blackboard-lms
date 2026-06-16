# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/wizard/configure_video', type: :view do
  let(:templates) do
    [
      ContentStudio::VideoTemplate.new(id: 1, name: 'Classic', thumbnail_url: nil),
      ContentStudio::VideoTemplate.new(id: 2, name: 'Modern', thumbnail_url: 'https://example.com/modern.png')
    ]
  end

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:course_id, 1)
    assign(:templates, templates)
    allow(ContentStudio::ApiClient).to receive(:list_templates).and_return(templates)
  end

  it 'renders Configure Video as the active wizard step' do
    render
    expect(rendered).to include('Configure Video')
  end

  it 'renders all wizard step labels' do
    render
    expect(rendered).to include('Upload doc')
    expect(rendered).to include('Course Structure')
  end

  it 'renders the Choose Template section' do
    render
    expect(rendered).to include('Choose Template')
  end

  it 'renders a radio input for each template' do
    render
    expect(rendered).to include('value="1"')
    expect(rendered).to include('value="2"')
  end

  it 'pre-selects the first template' do
    render
    expect(rendered).to match(/value="1"[^>]*checked|checked[^>]*value="1"/)
  end

  it 'renders the template name as fallback when thumbnail_url is absent' do
    render
    expect(rendered).to include('Classic')
  end

  it 'renders a thumbnail image when thumbnail_url is present' do
    render
    expect(rendered).to include('modern.png')
  end

  it 'renders the Video Style Preview panel' do
    render
    expect(rendered).to include('Video Style Preview')
  end

  it 'renders the Upload Logo section' do
    render
    expect(rendered).to include('Upload Logo')
  end

  it 'renders the footer buttons' do
    render
    expect(rendered).to include('Back to Upload')
    expect(rendered).to include('Generate Course')
  end
end
