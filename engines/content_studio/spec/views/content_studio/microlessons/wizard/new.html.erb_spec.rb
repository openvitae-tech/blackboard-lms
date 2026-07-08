# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/microlessons/wizard/new', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:title, nil)
    assign(:prompt, nil)
  end

  it 'renders all three wizard step labels' do
    render
    expect(rendered).to include('Prompt')
    expect(rendered).to include('Configure Video')
    expect(rendered).to include('Script Review')
  end

  it 'renders the Microlesson title field' do
    render
    expect(rendered).to include('Microlesson title')
  end

  it 'renders the prompt textarea label' do
    render
    expect(rendered).to include('What should this microlesson teach?')
  end

  it 'renders the character counter target and limit' do
    render
    expect(rendered).to include('data-char-counter-target="count"')
    expect(rendered).to include('/ 500')
  end

  it 'renders the Cancel and Continue footer buttons' do
    render
    expect(rendered).to include('Cancel')
    expect(rendered).to include('Continue to Video style')
  end

  context 'when session has previously entered values' do
    before do
      assign(:title, 'KYC Refresher')
      assign(:prompt, 'Explain KYC verification steps.')
    end

    it 'pre-fills the title field' do
      render
      expect(rendered).to include('value="KYC Refresher"')
    end

    it 'pre-fills the prompt textarea' do
      render
      expect(rendered).to include('Explain KYC verification steps.')
    end
  end
end
