# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CourseCertificate, type: :model do
  let(:learner) { create :user, :learner }
  let(:learning_partner) { create(:learning_partner) }
  let(:course) { create :course }
  let(:certificate_template) { create(:certificate_template, learning_partner:) }
  let(:course_certificate) { create(:course_certificate, course:, user: learner, certificate_template:) }

  describe '#issued_at' do
    it 'is not valid without issued_at' do
      course_certificate.issued_at = ''

      expect(course_certificate).not_to be_valid
      expect(course_certificate.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                                          field: 'Issued at'))
    end
  end

  describe '#file_hash' do
    it 'is not valid without file_hash' do
      course_certificate.file_hash = ''

      expect(course_certificate).not_to be_valid
      expect(course_certificate.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                                          field: 'File hash'))
    end
  end

  describe '#certificate_id' do
    it 'is not valid without certificate_id' do
      course_certificate.certificate_id = ''

      expect(course_certificate).not_to be_valid
      expect(course_certificate.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                                          field: 'Certificate'))
    end
  end

  describe '#user_id' do
    it 'is not valid without user' do
      course_certificate.user = nil

      expect(course_certificate).not_to be_valid
      expect(course_certificate.errors.full_messages.to_sentence).to eq(t('must_exist',
                                                                          entity: 'User'))
    end
  end

  describe '#certificate_template_id' do
    it 'is not valid without user' do
      course_certificate.certificate_template = nil

      expect(course_certificate).not_to be_valid
      expect(course_certificate.errors.full_messages.to_sentence).to eq(t('must_exist',
                                                                          entity: 'Certificate template'))
    end
  end

  describe '#course_id' do
    it 'is not valid without user' do
      course_certificate.course = nil

      expect(course_certificate).not_to be_valid
      expect(course_certificate.errors.full_messages.to_sentence).to eq(t('must_exist',
                                                                          entity: 'Course'))
    end
  end
end
