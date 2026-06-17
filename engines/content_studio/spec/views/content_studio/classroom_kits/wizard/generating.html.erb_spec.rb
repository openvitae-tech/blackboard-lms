# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/classroom_kits/wizard/generating', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
  end

  it 'renders all three wizard step labels' do
    assign(:state, 'pending')
    render
    expect(rendered).to include('Upload doc')
    expect(rendered).to include('Configure Kit')
    expect(rendered).to include('Kit Structure')
  end

  context 'when state is pending' do
    before { assign(:state, 'pending') }

    it 'mounts the generation-polling controller' do
      render
      expect(rendered).to include('data-controller="generation-polling"')
    end

    it 'sets the start-url-value data attribute to the start_kit_generation path' do
      render
      expect(rendered).to include('data-generation-polling-start-url-value=')
    end

    it 'renders the uploadPhase target' do
      render
      expect(rendered).to include('data-generation-polling-target="uploadPhase"')
    end

    it 'renders the craftingPhase target' do
      render
      expect(rendered).to include('data-generation-polling-target="craftingPhase"')
    end

    it 'renders the uploading heading' do
      render
      expect(rendered).to include('Uploading your document')
    end
  end

  context 'when state is error' do
    before { assign(:state, 'error') }

    it 'renders the error partial' do
      render
      expect(rendered).to include("couldn't create your kit")
    end

    it 'does not render the polling controller' do
      render
      expect(rendered).not_to include('data-controller="generation-polling"')
    end
  end
end
