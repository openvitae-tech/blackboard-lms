# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/classroom_kits/wizard/generating', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:kit_id, 'pending')
  end

  it 'renders all three wizard step labels' do
    render
    expect(rendered).to include('Upload doc')
    expect(rendered).to include('Configure Kit')
    expect(rendered).to include('Kit Structure')
  end

  it 'marks Kit Structure as the active step' do
    render
    expect(rendered).to include('border-2 border-primary')
  end

  it 'renders the uploading heading' do
    render
    expect(rendered).to include('Uploading your document')
  end

  it 'renders the hold tight message' do
    render
    expect(rendered).to include('Hold tight! Your file is on its way.')
  end

  describe 'Stimulus generation-polling controller integration' do
    before { render }

    it 'mounts the generation-polling controller on the root element' do
      expect(rendered).to include('data-controller="generation-polling"')
    end

    it 'sets the status-url value attribute for polling' do
      expect(rendered).to include('data-generation-polling-status-url-value')
    end

    it 'renders the uploadPhase target' do
      expect(rendered).to include('data-generation-polling-target="uploadPhase"')
    end

    it 'renders the craftingPhase target' do
      expect(rendered).to include('data-generation-polling-target="craftingPhase"')
    end

    it 'renders the errorPhase target' do
      expect(rendered).to include('data-generation-polling-target="errorPhase"')
    end
  end
end
