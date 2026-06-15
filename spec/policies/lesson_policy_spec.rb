# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LessonPolicy do
  let(:learning_partner) { create :learning_partner }
  let(:team) { create :team, learning_partner: }
  let(:admin) { create :user, :admin }
  let(:manager) { create :user, :manager, team:, learning_partner: }
  let(:learner) { create :user, :learner, team:, learning_partner: }

  let(:course) { create :course, learning_partner: }
  let(:course_module) { create :course_module, course: }
  let(:lesson) { create :lesson, course_module: }

  describe '#show?' do
    context 'when record is a Course (as authorized in LessonsController#show)' do
      subject { described_class.new(user, course).show? }

      context 'admin' do
        let(:user) { admin }

        it { is_expected.to be true }
      end

      context 'manager whose learning partner owns a content studio course' do
        let(:user) { manager }

        before { course.update!(neo_ai_course_id: 'neo-123') }

        it { is_expected.to be true }
      end

      context 'manager on a non-content-studio course' do
        let(:user) { manager }

        it { is_expected.to be false }
      end

      context 'enrolled learner' do
        let(:user) { learner }

        before { Enrollment.create!(user: learner, course:) }

        it { is_expected.to be true }
      end

      context 'unenrolled learner' do
        let(:user) { learner }

        it { is_expected.to be false }
      end
    end
  end

  describe '#new? / #create? / #edit? / #update?' do
    let(:cs_course) { create :course, learning_partner:, neo_ai_course_id: 'neo-456' }
    let(:cs_module) { create :course_module, course: cs_course }
    let(:cs_lesson) { create :lesson, course_module: cs_module }

    %i[new? create?].each do |action|
      describe "##{action}" do
        it 'permits admin' do
          expect(described_class.new(admin, lesson).public_send(action)).to be true
        end

        it 'permits manager who owns the content studio course' do
          expect(described_class.new(manager, cs_lesson).public_send(action)).to be true
        end

        it 'denies manager on a non-content-studio course' do
          expect(described_class.new(manager, lesson).public_send(action)).to be false
        end
      end
    end

    %i[edit? update?].each do |action|
      describe "##{action}" do
        it 'permits admin' do
          expect(described_class.new(admin, lesson).public_send(action)).to be true
        end

        it 'permits manager who owns the content studio course' do
          expect(described_class.new(manager, cs_lesson).public_send(action)).to be true
        end

        it 'denies manager on a non-content-studio course' do
          expect(described_class.new(manager, lesson).public_send(action)).to be false
        end
      end
    end
  end

  describe '#complete?' do
    it 'permits enrolled learner' do
      Enrollment.create!(user: learner, course:)
      expect(described_class.new(learner, lesson).complete?).to be true
    end

    it 'denies unenrolled user' do
      expect(described_class.new(learner, lesson).complete?).to be false
    end
  end

  describe '#transcribe?' do
    it 'permits admin' do
      expect(described_class.new(admin, lesson).transcribe?).to be true
    end

    it 'denies manager' do
      expect(described_class.new(manager, lesson).transcribe?).to be false
    end
  end
end
