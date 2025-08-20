# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ChannelMessageTemplates do
  subject { described_class.new }

  describe '#course_assigned_template' do
    it 'returns the correct SMS and WhatsApp templates' do
      fast2_sms_template = Rails.application.credentials.dig(:fast2sms, :template, :course_assigned)
      msg91_template = Rails.application.credentials.dig(:msg91, :template, :course_assigned)
      expect(subject.course_assigned_template).to eq({
                                                       sms: {
                                                         'fast2_sms' => fast2_sms_template,
                                                         'msg91' => msg91_template
                                                       },
                                                       whatsapp: 'course_assigned'
                                                     })
    end
  end

  describe '#course_enrolled_template' do
    it 'returns the correct SMS and WhatsApp templates' do
      fast2_sms_template = Rails.application.credentials.dig(:fast2sms, :template, :course_enrolled)
      msg91_template = Rails.application.credentials.dig(:msg91, :template, :course_enrolled)

      expect(subject.course_enrolled_template).to eq({
                                                       sms: {
                                                         'fast2_sms' => fast2_sms_template,
                                                         'msg91' => msg91_template
                                                       },
                                                       whatsapp: 'course_enrolled'
                                                     })
    end
  end

  describe '#welcome_template' do
    it 'returns the correct SMS and WhatsApp templates' do
      fast2_sms_template = Rails.application.credentials.dig(:fast2sms, :template, :welcome)
      msg91_template = Rails.application.credentials.dig(:msg91, :template, :welcome)

      expect(subject.welcome_template).to eq({
                                               sms: {
                                                 'fast2_sms' => fast2_sms_template,
                                                 'msg91' => msg91_template
                                               },
                                               whatsapp: 'welcome'
                                             })
    end
  end

  describe '#sms_otp_template' do
    it 'returns the SMS otp template' do
      fast2_sms_template = Rails.application.credentials.dig(:fast2sms, :template, :otp)
      msg91_template = Rails.application.credentials.dig(:msg91, :template, :otp)

      expect(subject.otp_template).to eq({
                                           sms: {
                                             'fast2_sms' => fast2_sms_template,
                                             'msg91' => msg91_template
                                           }
                                         })
    end
  end

  describe 'undefined method' do
    it 'raises NoMethodError for undefined method' do
      expect { subject.test_template }.to raise_error(NoMethodError)
    end
  end
end
