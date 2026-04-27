# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/wizard/generating', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:course_id, 1)
  end

  it 'renders Course Structure as the active wizard step' do
    render
    expect(rendered).to include('Course Structure')
  end

  it 'renders all wizard step labels' do
    render
    expect(rendered).to include('Upload doc')
    expect(rendered).to include('Configure Video')
  end

  it 'renders the lottie animation player' do
    render
    expect(rendered).to include('lottie-player')
  end

  it 'renders the waiting message' do
    render
    expect(rendered).to include("We're creating your course structure")
    expect(rendered).to include('Please be patient')
  end

  it 'wires the generation-polling Stimulus controller' do
    render
    expect(rendered).to include('data-controller="generation-polling"')
    expect(rendered).to include('data-generation-polling-status-url-value')
  end
end
