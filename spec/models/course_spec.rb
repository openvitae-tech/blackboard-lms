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
    it "calculates the total duration of the course recursively" do
      course = create :course
      expect(course.duration).to eq(0)
    end
  end
end
