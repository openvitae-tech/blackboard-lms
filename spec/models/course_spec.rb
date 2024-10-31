# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Course, type: :model do
  describe '#enroll!' do
    subject { create :course }

    before(:each) do
      @user = create :user, :learner
    end

    let(:user) { @user }

    it 'creates a new enrollment' do
      expect(subject.enroll!(user)).to be_truthy
    end

    it 'cannot add a duplicate enrollment' do
      subject.enroll!(user)
      expect { subject.enroll!(user) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it 'add a new enrollment record for the course' do
      expect { subject.enroll!(user) }.to change { subject.enrollments.count }.by(1)
    end

    it 'add a new enrollment record for the user' do
      expect { subject.enroll!(user) }.to change { user.enrollments.count }.by(1)
    end

    it 'add a new enrollment record for the user with an assigned_by user record' do
      manager = create :user, :manager
      subject.enroll!(user, manager)
      expect(user.enrollments.last.assigned_by).to eql(manager)
    end
  end

  describe '#undo_enroll!' do
    subject { create :course }

    before(:each) do
      @user = create :user, :learner
      subject.enroll!(@user)
    end

    let(:user) { @user }

    it 'deletes the enrollment' do
      expect(subject.undo_enroll!(user)).to be_truthy
    end

    it 'removes the enrollment for the course' do
      expect { subject.undo_enroll!(user) }.to change { subject.enrollments.count }.by(-1)
    end

    it 'removes the enrollment for the user' do
      expect { subject.undo_enroll!(user) }.to change { user.enrollments.count }.by(-1)
    end
  end

  describe '#duration' do
    it 'calculates the duration to zero for an empty course' do
      course = create :course
      expect(course.duration).to eq(0)
    end

    it 'calculates the total duration of the course recursively' do
      course = course_with_associations(modules_count: 3, lessons_count: 2, quizzes_count: 1, duration: 10)
      expect(course.duration).to eq(3 * 2 * 10)
    end
  end

  describe '#lessons_count' do
    it 'calculates number of lessons in an empty course' do
      course = create :course
      expect(course.lessons_count).to eq(0)
    end

    it 'calculates number of lessons in a course' do
      course = course_with_associations
      expect(course.lessons_count).to eq(1)
    end
  end

  describe '#quizzes_count' do
    it 'calculates number of quizzes in an empty course' do
      course = create :course
      expect(course.quizzes_count).to eq(0)
    end

    it 'calculates number of quizzes in a course' do
      course = course_with_associations
      expect(course.quizzes_count).to eq(1)
    end
  end

  describe '#first_module' do
    it 'returns nil if there are no modules within a course' do
      course = create :course
      expect(course.first_module).to be_nil
    end

    it 'returns the first module within a course' do
      course = course_with_associations
      expect(course.first_module.id).to eq(course.course_modules_in_order.first)
    end
  end

  describe '#last_module' do
    it 'returns nil if there are no modules within a course' do
      course = create :course
      expect(course.last_module).to be_nil
    end

    it 'returns the first module within a course' do
      course = course_with_associations
      expect(course.last_module.id).to eq(course.course_modules_in_order.last)
    end
  end

  describe '#next_module' do
    it 'returns nil if there are no further modules' do
      course = course_with_associations
      expect(course.next_module(course.last_module)).to be_nil
    end

    it 'returns next module if there are other modules' do
      course = course_with_associations(modules_count: 2)
      expect(course.next_module(course.first_module)).to eq(course.last_module)
    end
  end

  describe '#prev_module' do
    it 'returns nil if there are no previous modules' do
      course = course_with_associations
      expect(course.prev_module(course.first_module)).to be_nil
    end

    it 'returns previous module' do
      course = course_with_associations(modules_count: 2)
      expect(course.prev_module(course.last_module)).to eq(course.first_module)
    end
  end

  describe '#published?' do
    it 'returns false if the module is not published' do
      course = course_with_associations
      expect(course.published?).to be_falsey
    end

    it 'returns true if the module is not published' do
      course = course_with_associations
      course.update(is_published: true)
      expect(course.published?).to be_truthy
    end
  end

  describe '#publish!' do
    it 'marks the course as published' do
      course = course_with_associations
      course.publish!
      expect(course.published?).to be_truthy
    end
  end

  describe '#undo_publish!' do
    it 'marks the course as unpublished' do
      course = course_with_associations
      course.undo_publish!
      expect(course.published?).to be_falsey
    end
  end
end
