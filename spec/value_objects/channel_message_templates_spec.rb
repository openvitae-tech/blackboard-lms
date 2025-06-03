# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChannelMessageTemplates do
  subject { described_class.new }

  describe '#course_assigned_template' do
    it 'returns the correct SMS and WhatsApp templates' do
      expected_sms = Rails.application.credentials.dig(:fast2sms, :template, :course_assigned)
      expect(subject.course_assigned_template).to eq({
                                                       sms: expected_sms,
                                                       whatsapp: 'course_assigned'
                                                     })
    end
  end

  describe '#course_enrolled_template' do
    it 'returns the correct SMS and WhatsApp templates' do
      expected_sms = Rails.application.credentials.dig(:fast2sms, :template, :course_enrolled)
      expect(subject.course_enrolled_template).to eq({
                                                       sms: expected_sms,
                                                       whatsapp: 'course_enrolled'
                                                     })
    end
  end

  describe '#sms_otp_template' do
    it 'returns the SMS otp template' do
      expected_sms = Rails.application.credentials.dig(:fast2sms, :template, :otp)
      expect(subject.sms_otp_template).to eq({
                                               sms: expected_sms
                                             })
    end
  end

  describe 'undefined method' do
    it 'raises NoMethodError for undefined method' do
      expect { subject.test_template }.to raise_error(NoMethodError)
    end
  end
end
