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

  before do
    create :payment_plan, learning_partner:, content_studio_enabled: true
  end

  describe '#show?' do
    let(:cs_lesson) do
      cs_course = create :course, learning_partner:, neo_ai_course_id: 'neo-123'
      create :lesson, course_module: (create :course_module, course: cs_course)
    end

    it 'permits admin' do
      expect(described_class.new(admin, lesson).show?).to be true
    end

    it 'permits manager of a content studio learning partner' do
      expect(described_class.new(manager, cs_lesson).show?).to be true
    end

    it 'denies manager on a non-content-studio course' do
      expect(described_class.new(manager, lesson).show?).to be false
    end

    it 'permits enrolled learner' do
      Enrollment.create!(user: learner, course:)
      expect(described_class.new(learner, lesson).show?).to be true
    end

    it 'denies unenrolled learner' do
      expect(described_class.new(learner, lesson).show?).to be false
    end
  end

  describe '#new?' do
    it 'permits admin' do
      expect(described_class.new(admin, lesson).new?).to be true
    end

    it 'denies manager' do
      expect(described_class.new(manager, lesson).new?).to be false
    end
  end

  describe '#create?' do
    it 'permits admin' do
      expect(described_class.new(admin, lesson).create?).to be true
    end

    it 'denies manager' do
      expect(described_class.new(manager, lesson).create?).to be false
    end
  end

  describe '#edit?' do
    it 'permits admin' do
      expect(described_class.new(admin, lesson).edit?).to be true
    end

    it 'denies manager' do
      expect(described_class.new(manager, lesson).edit?).to be false
    end
  end

  describe '#update?' do
    it 'permits admin' do
      expect(described_class.new(admin, lesson).update?).to be true
    end

    it 'denies manager' do
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
