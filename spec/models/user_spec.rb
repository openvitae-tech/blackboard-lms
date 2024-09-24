# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#set_temp_password' do
    subject { User.new }

    it 'sets an encrypted temporary temporary password for the user' do
      allow(subject).to receive(:password_verifier).and_return('test_verifier')
      subject.set_temp_password
      expect(subject.temp_password_enc).not_to be_empty
    end
  end

  describe '#get_temp_password' do
    subject { User.new }

    it 'decrypts the temporary password for the user' do
      allow(subject).to receive(:password_verifier).and_return('test_verifier')
      subject.set_temp_password
      expect(subject.get_temp_password).not_to be_empty
    end
  end

  describe '#enrolled_for_course?' do
    subject { User.new }

    it 'checks if the give user is enrolled for a particular course' do
      course = create :course
      user = create :user, :learner
      expect(user.enrolled_for_course?(course)).to be_falsey
      course.enroll!(user)
      expect(user.enrolled_for_course?(course)).to be_truthy
    end
  end

  describe '#get_enrollment_for' do
    subject { User.new }

    it "returns user's enrollment records for a course" do
      course = create :course
      user = create :user, :learner
      expect(user.get_enrollment_for(course)).to be_nil
      course.enroll!(user)
      expect(user.get_enrollment_for(course)).not_to be_nil
    end
  end
end
