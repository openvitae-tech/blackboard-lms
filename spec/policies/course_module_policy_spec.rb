# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseModulePolicy do
  let(:learning_partner) { create :learning_partner }
  let(:team) { create :team, learning_partner: }
  let(:admin) { create :user, :admin }
  let(:manager) { create :user, :manager, team:, learning_partner: }

  let(:course) { create :course, learning_partner: }
  let(:course_module) { create :course_module, course: }

  let(:cs_course) { create :course, learning_partner:, neo_ai_course_id: 'neo-123' }
  let(:cs_module) { create :course_module, course: cs_course }

  %i[new? create? edit? update? show?].each do |action|
    describe "##{action}" do
      it 'permits admin' do
        expect(described_class.new(admin, course_module).public_send(action)).to be true
      end

      it 'denies manager even on a content studio course' do
        expect(described_class.new(manager, cs_module).public_send(action)).to be false
      end

      it 'denies manager on a non-content-studio course' do
        expect(described_class.new(manager, course_module).public_send(action)).to be false
      end
    end
  end
end
