require 'rails_helper'

RSpec.describe Course, type: :model do
  describe "#enroll!" do
    subject { create :course }

    before(:each) do
      @user = create :user, :learner
    end

    let(:user) { @user }

    it "creates a new enrollment" do
      expect(subject.enroll!(user)).to be_truthy
    end

    it "cannot add a duplicate enrollment" do
      subject.enroll!(user)
      expect { subject.enroll!(user) }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "add a new enrollment record for the course" do
      expect { subject.enroll!(user) }.to change { subject.enrollments.count }.by(1)
    end

    it "add a new enrollment record for the user" do
      expect { subject.enroll!(user) }.to change { user.enrollments.count }.by(1)
    end
  end

  describe "#undo_enroll!" do
    subject { create :course }

    before(:each) do
      @user = create :user, :learner
      subject.enroll!(@user)
    end

    let(:user) { @user }

    it "deletes the enrollment" do
      expect(subject.undo_enroll!(user)).to be_truthy
    end

    it "removes the enrollment for the course" do
      expect { subject.undo_enroll!(user) }.to change { subject.enrollments.count }.by(-1)
    end

    it "removes the enrollment for the user" do
      expect { subject.undo_enroll!(user) }.to change { user.enrollments.count }.by(-1)
    end
  end

  describe "#duration" do
    it "calculates the duration to zero for an empty course" do
      course = create :course
      expect(course.duration).to eq(0)
    end

    it "calculates the total duration of the course recursively" do
      course = course_with_associations(modules_count: 3, lessons_count: 2, quizzes_count: 1, duration: 10)
      expect(course.duration).to eq(3 * 2 * 10)
    end
  end

  describe "#lessons_count" do
    it "calculates number of lessons in an empty course" do
      course = create :course
      expect(course.lessons_count).to eq(0)
    end

    it "calculates number of lessons in a course" do
      course = course_with_associations
      expect(course.lessons_count).to eq(1)
    end
  end

  describe "#quizzes_count" do
    it "calculates number of quizzes in an empty course" do
      course = create :course
      expect(course.quizzes_count).to eq(0)
    end

    it "calculates number of quizzes in a course" do
      course = course_with_associations
      expect(course.quizzes_count).to eq(1)
    end
  end
end
