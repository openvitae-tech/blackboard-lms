# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/wizard/configure_video', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:course_id, 1)
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

  it 'renders the Upload Logo section' do
    render
    expect(rendered).to include('Upload Logo')
  end

  it 'renders the Colour Branding section with updated field labels' do
    render
    expect(rendered).to include('Colour Branding')
    expect(rendered).to include('Background Colour')
    expect(rendered).to include('Text Colour')
  end

  it 'renders the footer buttons' do
    render
    expect(rendered).to include('Back to Upload')
    expect(rendered).to include('Generate Course')
  end
end
