# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/classroom_kits/wizard/_success', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    render
  end

  it 'renders the success heading' do
    expect(rendered).to include('Your kit is ready!')
  end

  it 'renders the success body message' do
    expect(rendered).to include('Your classroom kit has been created successfully.')
  end

  it 'renders a check-circle icon' do
    expect(rendered).to include('text-secondary')
    expect(rendered).to include('bg-secondary-light')
  end
end
