# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/classroom_kits/structure/show', type: :view do
  before do
    view.singleton_class.define_method(:alert_modal_path) { |**_| '/alert_modal' }
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:kit, kit)
  end

  let(:slide_deck_component) do
    ContentStudio::KitComponent.new(
      id: 'comp-1', type: 'slide_deck', title: nil,
      status: 'READY', download_url: 'https://s3.example.com/slide_deck.pptx'
    )
  end

  let(:trainer_guide_component) do
    ContentStudio::KitComponent.new(
      id: 'comp-2', type: 'trainer_guide', title: nil,
      status: 'PENDING', download_url: nil
    )
  end

  let(:kit) do
    ContentStudio::Kit.new(
      id: 'kit-123', title: 'Banking Basics', status: 'COMPLETED',
      stage: 'ready', thumbnail_url: nil, doc_count: 0,
      components: [slide_deck_component, trainer_guide_component],
      saved: false
    )
  end

  it 'renders the kit title in the header' do
    render
    expect(rendered).to include('Banking Basics')
  end

  it 'falls back to Untitled Kit when title is nil' do
    assign(:kit, ContentStudio::Kit.new(**kit.to_h, title: nil))
    render
    expect(rendered).to include('Untitled Kit')
  end

  it 'renders the progress banner with percentage' do
    render
    expect(rendered).to include('50%')
  end

  it 'renders the component count in the summary card' do
    render
    expect(rendered).to include('2 Components')
  end

  it 'renders a download link for READY components' do
    render
    expect(rendered).to include('classroom-kits/kit-123/components/comp-1/download')
  end

  it 'renders a spinner for PENDING components' do
    render
    expect(rendered).to include('animate-spin')
  end

  it 'renders human-readable component labels' do
    render
    expect(rendered).to include('Slide deck for learners')
    expect(rendered).to include('Trainer guide')
  end

  it 'mounts the structure-polling controller' do
    render
    expect(rendered).to include('data-controller="structure-polling"')
  end

  it 'sets pending to true when not all components are READY' do
    render
    expect(rendered).to include('data-structure-polling-pending-value="true"')
  end

  it 'renders the Save Kit button when kit is not saved to LMS' do
    render
    expect(rendered).to include('Save Kit')
  end

  it 'does not render Update Kit when kit is not saved' do
    render
    expect(rendered).not_to include('Update Kit')
  end

  context 'when kit is already saved to LMS' do
    before { assign(:kit, ContentStudio::Kit.new(**kit.to_h, saved: true)) }

    it 'renders the Update Kit button' do
      render
      expect(rendered).to include('Update Kit')
    end

    it 'does not render Save Kit when kit is already saved' do
      render
      expect(rendered).not_to include('Save Kit')
    end
  end

  it 'does not hide the progress banner when not all components are ready' do
    render
    expect(rendered).to include('data-structure-polling-target="banner"')
    expect(rendered).not_to include('visibility: hidden')
  end

  context 'when all components are READY' do
    let(:kit) do
      ContentStudio::Kit.new(
        id: 'kit-123', title: 'Banking Basics', status: 'COMPLETED',
        stage: 'ready', thumbnail_url: nil, doc_count: 0,
        components: [slide_deck_component],
        saved: false
      )
    end

    it 'sets pending to false' do
      render
      expect(rendered).to include('data-structure-polling-pending-value="false"')
    end

    it 'renders the Download All button' do
      render
      expect(rendered).to include('Download All')
    end

    it 'shows Kit is ready in the banner' do
      render
      expect(rendered).to include('Kit is ready')
    end

    it 'hides the progress banner server-side' do
      render
      expect(rendered).to include('visibility: hidden')
    end
  end

  it 'renders the Discard Kit button as a modal link to the alert_modal' do
    render
    expect(rendered).to include('/alert_modal')
    expect(rendered).to include('Discard Kit')
  end

  context 'when a component has FAILED' do
    let(:failed_component) do
      ContentStudio::KitComponent.new(
        id: 'comp-3', type: 'assessment', title: nil,
        status: 'FAILED', download_url: nil
      )
    end

    before do
      assign(:kit, ContentStudio::Kit.new(**kit.to_h, components: [failed_component]))
    end

    it 'renders a danger icon for FAILED components' do
      render
      expect(rendered).to include('text-danger')
    end
  end
end
