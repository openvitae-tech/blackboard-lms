# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/classroom_kits/wizard/configure', type: :view do
  let(:all_components) { %w[slide_deck trainer_guide learner_workbook assessment quiz] }

  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:kit_id, 'pending')
    assign(:selected_components, all_components)
  end

  it 'renders all three wizard step labels' do
    render
    expect(rendered).to include('Upload doc')
    expect(rendered).to include('Configure Kit')
    expect(rendered).to include('Kit Structure')
  end

  it 'renders all five component checkboxes' do
    render
    expect(rendered).to include('Slide deck for learners')
    expect(rendered).to include('Trainer guide')
    expect(rendered).to include('Learner handouts')
    expect(rendered).to include('Learning Notes')
    expect(rendered).to include('Quiz')
  end

  it 'renders all five checkboxes as checked by default' do
    render
    expect(rendered.scan('checked').size).to be >= 5
  end

  it 'renders the Back and Generate Kit Structure footer buttons' do
    render
    expect(rendered).to include('Back')
    expect(rendered).to include('Generate Kit Structure')
  end

  it 'mounts the kit-configure Stimulus controller on the form' do
    render
    expect(rendered).to include('data-controller="kit-configure"')
  end

  it 'sets kit-configure checkbox targets and change actions on checkboxes' do
    render
    expect(rendered).to include('data-kit-configure-target="checkbox"')
    expect(rendered).to include('data-action="change-&gt;kit-configure#onCheckboxChanged"')
  end

  it 'sets kit-configure submit target on the submit button' do
    render
    expect(rendered).to include('data-kit-configure-target="submit"')
  end

  context 'when no components are selected' do
    before do
      assign(:selected_components, [])
    end

    it 'renders no checkboxes as checked' do
      render
      expect(rendered).not_to include('checked="checked"')
    end
  end

  context 'when only some components are selected' do
    before do
      assign(:selected_components, %w[trainer_guide quiz])
    end

    it 'renders only the selected components as checked' do
      render
      expect(rendered).to include('Trainer guide')
      expect(rendered).to include('Quiz')
    end
  end
end
