# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/classroom_kits/wizard/_error', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    render
  end

  it 'renders the error heading' do
    expect(rendered).to include("couldn't create your kit")
  end

  it 'renders the error body message' do
    expect(rendered).to include('Something interrupted the process')
  end

  it 'renders an Upload a different document button' do
    expect(rendered).to include('Upload a different document')
  end

  it 'renders a Retry button' do
    expect(rendered).to include('Retry')
  end

  it 'renders the error image' do
    expect(rendered).to include('alt="Error"')
  end
end
