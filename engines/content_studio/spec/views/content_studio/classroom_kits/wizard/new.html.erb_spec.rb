# frozen_string_literal: true

require_relative '../../../../rails_helper'

RSpec.describe 'content_studio/classroom_kits/wizard/new', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    assign(:existing_files, [])
  end

  it 'renders all three wizard step labels' do
    render
    expect(rendered).to include('Upload doc')
    expect(rendered).to include('Configure Kit')
    expect(rendered).to include('Kit Structure')
  end

  it 'marks Upload doc as the active step' do
    render
    expect(rendered).to include('Upload doc')
  end

  it 'renders the file upload card heading' do
    render
    expect(rendered).to include('Choose Classroom Kit Documents')
  end

  it 'renders the file selector support text' do
    render
    expect(rendered).to include('File types : pdf, png, jpeg, doc, docx')
    expect(rendered).to include('File size : 5 mb/file')
  end

  it 'renders the Back and Continue footer buttons' do
    render
    expect(rendered).to include('Back')
    expect(rendered).to include('Continue')
  end

  context 'when there are existing uploaded files in the session' do
    before do
      assign(:existing_files, [{ 'name' => 'guide.pdf', 'url' => 'https://example.com/guide.pdf' }])
    end

    it 'renders the existing file name' do
      render
      expect(rendered).to include('guide.pdf')
    end
  end
end
