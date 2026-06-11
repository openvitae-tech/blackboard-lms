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
    expect(rendered).to include('Kit Structure')
  end

  it 'renders the uploading heading' do
    render
    expect(rendered).to include('Uploading your document')
  end

  it 'renders the hold tight message' do
    render
    expect(rendered).to include('Hold tight! Your file is on its way.')
  end
end
