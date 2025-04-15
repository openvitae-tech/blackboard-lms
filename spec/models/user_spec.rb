# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user_one) { create :user, :learner }

  describe '#set_temp_password' do
    subject { described_class.new }

    it 'sets an encrypted temporary temporary password for the user' do
      allow(subject).to receive(:password_verifier).and_return('test_verifier')
      subject.set_temp_password
      expect(subject.temp_password_enc).not_to be_empty
    end
  end

  describe '#phone' do
    before do
      user_one.update!(phone: '1234567890')
    end

    it 'is unique' do
      user_two = build :user, :learner, phone: '1234567890'
      expect(user_two).not_to be_valid
      expect(user_two.errors.full_messages.to_sentence).to include(t('already_taken',
                                                                     field: 'Phone'))
    end
  end

  describe '#role' do
    it 'able to create support user' do
      user = create :user, role: 'support'

      expect(user.role).to eq('support')
    end
  end

  describe '#privileged_user?' do
    it 'returns true for privileged user' do
      user = create :user, :owner

      expect(user.privileged_user?).to be true
    end

    it 'returns false for non-privileged user' do
      expect(user_one.privileged_user?).to be false
    end
  end

  describe '#otp' do
    before do
      otp = '123456'
      @encrypted_otp = Rails.application.message_verifier(password_verifier).generate(otp)
      user_one.update!(otp: @encrypted_otp, otp_generated_at: DateTime.now)
    end

    it 'is unique' do
      user_two = build :user, :learner, otp: @encrypted_otp
      expect(user_two).not_to be_valid
      expect(user_two.errors.full_messages.to_sentence).to include(t('already_taken',
                                                                     field: 'Otp'))
    end

    it 'does not regenerate OTP if otp requested within 5 minutes' do
      encrypted_old_otp = user_one.otp

      user_one.set_otp!
      expect(encrypted_old_otp).to eq(user_one.otp)
    end

    it 'when OTP is expired' do
      user_one.update!(otp_generated_at: 10.minutes.ago)
      encrypted_old_otp = user_one.otp

      user_one.set_otp!
      expect(encrypted_old_otp).not_to eq(user_one.otp)
    end

    it 'ables to generate otp' do
      user_two = create :user, :learner
      user_two.set_otp!

      expect(user_two.otp).not_to be_nil
    end

    it 'able to clear otp' do
      user_one.clear_otp!

      expect(user_one.otp).to be_nil
    end
  end

  describe '#temp_password' do
    subject { described_class.new }

    it 'decrypts the temporary password for the user' do
      allow(subject).to receive(:password_verifier).and_return('test_verifier')
      subject.set_temp_password
      expect(subject.temp_password).not_to be_empty
    end
  end

  describe '#enrolled_for_course?' do
    subject { described_class.new }

    it 'checks if the give user is enrolled for a particular course' do
      course = create :course
      user = create :user, :learner
      expect(user).not_to be_enrolled_for_course(course)
      course.enroll!(user)
      expect(user).to be_enrolled_for_course(course)
    end
  end

  describe '#get_enrollment_for' do
    subject { described_class.new }

    it "returns user's enrollment records for a course" do
      course = create :course
      user = create :user, :learner
      expect(user.get_enrollment_for(course)).to be_nil
      course.enroll!(user)
      expect(user.get_enrollment_for(course)).not_to be_nil
    end
  end

  describe '#update_active_users_count' do
    it 'decrements active users count when user state changes to inactive' do
      expect do
        user_one.update!(state: 'in-active')
      end.to change { user_one.learning_partner.active_users_count }.by(-1)
    end

    it 'increment active users count when user state changes to active' do
      user_one.update!(state: 'in-active')
      expect do
        user_one.update!(state: 'active')
      end.to change { user_one.learning_partner.active_users_count }.by(1)
    end
  end

  describe '#communication_channel' do
    it 'assign sms as default communication_channel' do
      user = create :user, :learner
      expect(user.communication_channel).to eq('sms')
    end
  end

  private

  def password_verifier
    Rails.application.credentials[:password_verifier]
  end
end
