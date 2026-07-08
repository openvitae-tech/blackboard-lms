# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/microlessons/wizard/configure', type: :view do
  let(:templates) { [] }

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:microlesson_id, 'pending')
    assign(:templates, templates)
  end

  it 'renders all three wizard step labels' do
    render
    expect(rendered).to include('Prompt')
    expect(rendered).to include('Configure Video')
    expect(rendered).to include('Script Review')
  end

  it 'renders the Choose a video template section' do
    render
    expect(rendered).to include('Choose a video template')
  end

  it 'renders the Upload your logo section' do
    render
    expect(rendered).to include('Upload your logo')
  end

  it 'renders the Background style section' do
    render
    expect(rendered).to include('Background style')
  end

  it 'renders all three background style options' do
    render
    expect(rendered).to include('Image')
    expect(rendered).to include('Video')
    expect(rendered).to include('Plain')
  end

  it 'renders background style options using input_radio_component' do
    render
    expect(rendered).to include('background_style')
  end

  it 'renders the Back and Continue footer buttons' do
    render
    expect(rendered).to include('Back')
    expect(rendered).to include('Continue to script review')
  end

  it 'renders a no-templates message when templates are empty' do
    render
    expect(rendered).to include('No templates available.')
  end
end
