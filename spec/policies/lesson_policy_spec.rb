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

      context 'when user is admin' do
        let(:user) { admin }

        it { is_expected.to be true }
      end

      context 'when manager owns the content studio course' do
        let(:user) { manager }

        before { course.update!(neo_ai_course_id: 'neo-123') }

        it { is_expected.to be true }
      end

      context 'when manager does not own a content studio course' do
        let(:user) { manager }

        it { is_expected.to be false }
      end

      context 'when learner is enrolled' do
        let(:user) { learner }

        before { Enrollment.create!(user: learner, course:) }

        it { is_expected.to be true }
      end

      context 'without enrollment' do
        let(:user) { learner }

        it { is_expected.to be false }
      end
    end
  end

  describe '#new?' do
    let(:cs_course) { create :course, learning_partner:, neo_ai_course_id: 'neo-456' }

    it 'permits admin' do
      expect(described_class.new(admin, course).new?).to be true
    end

    it 'permits manager who owns the content studio course' do
      expect(described_class.new(manager, cs_course).new?).to be true
    end

    it 'denies manager on a non-content-studio course' do
      expect(described_class.new(manager, course).new?).to be false
    end
  end

  describe '#create?' do
    let(:cs_course) { create :course, learning_partner:, neo_ai_course_id: 'neo-456' }

    it 'permits admin' do
      expect(described_class.new(admin, course).create?).to be true
    end

    it 'permits manager who owns the content studio course' do
      expect(described_class.new(manager, cs_course).create?).to be true
    end

    it 'denies manager on a non-content-studio course' do
      expect(described_class.new(manager, course).create?).to be false
    end
  end

  describe '#edit?' do
    let(:cs_lesson) do
      cs_course = create :course, learning_partner:, neo_ai_course_id: 'neo-456'
      create :lesson, course_module: (create :course_module, course: cs_course)
    end

    it 'permits admin' do
      expect(described_class.new(admin, lesson).edit?).to be true
    end

    it 'permits manager who owns the content studio course' do
      expect(described_class.new(manager, cs_lesson).edit?).to be true
    end

    it 'denies manager on a non-content-studio course' do
      expect(described_class.new(manager, lesson).edit?).to be false
    end
  end

  describe '#update?' do
    let(:cs_lesson) do
      cs_course = create :course, learning_partner:, neo_ai_course_id: 'neo-456'
      create :lesson, course_module: (create :course_module, course: cs_course)
    end

    it 'permits admin' do
      expect(described_class.new(admin, lesson).update?).to be true
    end

    it 'permits manager who owns the content studio course' do
      expect(described_class.new(manager, cs_lesson).update?).to be true
    end

    it 'denies manager on a non-content-studio course' do
      expect(described_class.new(manager, lesson).update?).to be false
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
