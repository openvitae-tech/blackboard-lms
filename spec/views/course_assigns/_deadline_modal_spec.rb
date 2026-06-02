# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'course_assigns/_deadline_modal', type: :view do
  let(:team) { create(:team) }
  let(:learning_partner) { team.learning_partner }
  let(:courses) { Array.new(2) { course_with_associations(published: true) } }
  let(:submit_path) { course_assigns_path }

  def doc
    Nokogiri::HTML::DocumentFragment.parse(rendered)
  end

  describe 'Apply-to-All section' do
    let(:search_context) do
      SearchContext.new(context: SearchContext::TEAM_ASSIGN, options: { team: })
    end

    before do
      render partial: 'course_assigns/deadline_modal',
             locals: { courses:, search_context:, submit_path: }
    end

    it 'renders the Apply to All label' do
      expect(rendered).to include('Apply to All')
    end

    it 'renders the apply-all duration dropdown' do
      expect(doc.at_css('[data-deadline-modal-target="applyAllSelect"]')).to be_present
    end

    it 'renders the apply-all custom date wrapper hidden by default' do
      wrapper = doc.at_css('[data-deadline-modal-target="applyAllCustomDate"]')
      expect(wrapper).to be_present
      expect(wrapper['class']).to include('hidden')
    end
  end

  describe 'per-course rows' do
    let(:search_context) do
      SearchContext.new(context: SearchContext::TEAM_ASSIGN, options: { team: })
    end

    before do
      render partial: 'course_assigns/deadline_modal',
             locals: { courses:, search_context:, submit_path: }
    end

    it 'renders one row per course' do
      expect(doc.css('[data-deadline-modal-target="courseRow"]').count).to eq(courses.count)
    end

    it 'marks each row hidden by default' do
      doc.css('[data-deadline-modal-target="courseRow"]').each do |row|
        expect(row['class']).to include('hidden')
      end
    end

    it 'sets data-course-id on each row' do
      rendered_ids = doc.css('[data-deadline-modal-target="courseRow"]').map { |r| r['data-course-id'] }
      expect(rendered_ids).to match_array(courses.map(&:id).map(&:to_s))
    end

    it 'renders a duration dropdown for each course' do
      expect(doc.css('[data-deadline-modal-target="durationSelect"]').count).to eq(courses.count)
    end

    it 'renders a hidden custom-date wrapper per course' do
      doc.css('[data-deadline-modal-target="customDateWrapper"]').each do |wrapper|
        expect(wrapper['class']).to include('hidden')
      end
    end
  end

  describe 'form structure' do
    let(:search_context) do
      SearchContext.new(context: SearchContext::TEAM_ASSIGN, options: { team: })
    end

    before do
      render partial: 'course_assigns/deadline_modal',
             locals: { courses:, search_context:, submit_path: }
    end

    it 'renders a form with id deadline-form' do
      expect(doc.at_css('form#deadline-form')).to be_present
    end

    it 'sets the form action to submit_path' do
      expect(doc.at_css('form#deadline-form')['action']).to eq(submit_path)
    end

    it 'renders the courseIdInputs container inside the form' do
      expect(doc.at_css('form#deadline-form [data-deadline-modal-target="courseIdInputs"]')).to be_present
    end
  end

  describe 'team assignment' do
    let(:search_context) do
      SearchContext.new(context: SearchContext::TEAM_ASSIGN, options: { team: })
    end

    before do
      render partial: 'course_assigns/deadline_modal',
             locals: { courses:, search_context:, submit_path: }
    end

    it 'includes a hidden team_id field' do
      field = doc.at_css('form#deadline-form input[name="team_id"][type="hidden"]')
      expect(field).to be_present
      expect(field['value']).to eq(team.id.to_s)
    end

    it 'does not include a user_id field' do
      expect(doc.at_css('form#deadline-form input[name="user_id"]')).to be_nil
    end
  end

  describe 'user assignment' do
    let(:learner) { create(:user, :learner, team:, learning_partner:) }
    let(:search_context) do
      SearchContext.new(context: SearchContext::USER_ASSIGN, options: { user: learner })
    end

    before do
      render partial: 'course_assigns/deadline_modal',
             locals: { courses:, search_context:, submit_path: }
    end

    it 'includes a hidden user_id field' do
      field = doc.at_css('form#deadline-form input[name="user_id"][type="hidden"]')
      expect(field).to be_present
      expect(field['value']).to eq(learner.id.to_s)
    end

    it 'does not include a team_id field' do
      expect(doc.at_css('form#deadline-form input[name="team_id"]')).to be_nil
    end
  end

  describe 'footer buttons' do
    let(:search_context) do
      SearchContext.new(context: SearchContext::TEAM_ASSIGN, options: { team: })
    end

    before do
      render partial: 'course_assigns/deadline_modal',
             locals: { courses:, search_context:, submit_path: }
    end

    it 'renders a Cancel button wired to deadline-modal#cancel' do
      cancel = doc.css('button').find { |b| b.text.strip.include?('Cancel') }
      expect(cancel).to be_present
      expect(cancel['data-action']).to include('deadline-modal#cancel')
    end

    it 'renders a Confirm submit button linked to deadline-form' do
      confirm = doc.css('button').find { |b| b.text.strip.include?('Confirm') }
      expect(confirm).to be_present
      expect(confirm['form']).to eq('deadline-form')
    end
  end
end
