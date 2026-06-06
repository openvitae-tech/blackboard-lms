# frozen_string_literal: true

require_relative '../../../rails_helper'

RSpec.describe 'content_studio/creations/new', type: :view do
  before do
    view.singleton_class.include ContentStudio::Engine.routes.url_helpers
    render
  end

  it 'renders the page heading' do
    expect(rendered).to include('What do you want to create?')
  end

  it 'renders the subtitle' do
    expect(rendered).to include('Pick the output that matches how your learners will consume it.')
  end

  it 'renders the Online Course card' do
    expect(rendered).to include('Online Course')
    expect(rendered).to include('AI-built video lessons with quizzes')
  end

  it 'renders the Classroom Kit card' do
    expect(rendered).to include('Classroom Kit')
    expect(rendered).to include('trainer-led offline pack')
  end

  it 'renders the Microlesson card as disabled' do
    expect(rendered).to include('Microlesson')
    expect(rendered).to have_selector('input[type="radio"][value="microlesson"][disabled]')
  end

  it 'renders Online Course and Classroom Kit radio inputs as enabled' do
    expect(rendered).to have_selector('input[type="radio"][value="online_course"]:not([disabled])')
    expect(rendered).to have_selector('input[type="radio"][value="classroom_kit"]:not([disabled])')
  end

  it 'renders all three radio inputs in the same group' do
    expect(rendered).to have_selector('input[type="radio"][name="content_type"]', count: 3)
  end

  it 'renders the Continue button with the Stimulus target' do
    expect(rendered).to include('Continue')
    expect(rendered).to have_selector('[data-creation-type-target="continueButton"]')
  end

  it 'renders the Cancel button linking to root' do
    expect(rendered).to include('Cancel')
  end

  it 'sets the Stimulus controller on the container' do
    expect(rendered).to have_selector('[data-controller="creation-type"]')
  end
end
