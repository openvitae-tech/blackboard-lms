# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Scorm, type: :model do
  let(:scorm) { create :scorm }

  describe '#token' do
    it 'is not valid without token' do
      scorm.token = ''
      expect(scorm).not_to be_valid
      expect(scorm.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                  field: 'Token'))
    end

    it 'token should be unique' do
      new_scorm = build :scorm, token: scorm.token
      expect(new_scorm).not_to be_valid
      expect(new_scorm.errors.full_messages.to_sentence).to include(t('already_taken',
                                                                      field: 'Token'))
    end

    it 'ables to regenerate token' do
      old_token = scorm.token
      scorm.regenerate_scorm_token
      expect(scorm.token).not_to eq(old_token)
    end
  end

  describe '#learning_partner' do
    it 'is not valid without learning partner' do
      scorm.learning_partner = nil
      expect(scorm).not_to be_valid
      expect(scorm.errors.full_messages.to_sentence).to include(t('must_exist',
                                                                  entity: 'Learning partner'))
    end
  end
end
