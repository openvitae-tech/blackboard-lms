# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/courses/wizard/new', type: :view do
  let(:metadata) do
    ContentStudio::CourseMetadata.new(
      categories: ['Housekeeping', 'F&B'],
      languages: %w[English Malayalam]
    )
  end

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:metadata, metadata)
  end

  it 'renders all three wizard step labels' do
    render
    expect(rendered).to include('Upload doc')
    expect(rendered).to include('Configure Video')
    expect(rendered).to include('Course Structure')
  end

  it 'renders the file upload card heading' do
    render
    expect(rendered).to include('Choose Course Documents')
  end

  it 'renders the file selector support text' do
    render
    expect(rendered).to include('File types : pdf, png, jpeg, doc')
    expect(rendered).to include('File size : 10 mb/file')
  end

  it 'renders the Course Level dropdown' do
    render
    expect(rendered).to include('Course Level')
    expect(rendered).to include('Choose Course difficulty level')
  end

  it 'renders Course Category multi-select with metadata options' do
    render
    expect(rendered).to include('Course Category')
    expect(rendered).to include('Housekeeping')
  end

  it 'renders Languages multi-select with metadata options' do
    render
    expect(rendered).to include('Languages')
    expect(rendered).to include('English')
    expect(rendered).to include('Malayalam')
  end

  it 'renders the Special Instructions textarea' do
    render
    expect(rendered).to include('Special Instructions if any')
  end

  it 'renders the Cancel and Next footer buttons' do
    render
    expect(rendered).to include('Cancel')
    expect(rendered).to include('Next : Configure Video Style')
  end
end
