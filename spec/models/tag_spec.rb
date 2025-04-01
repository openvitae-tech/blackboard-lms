# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tag, type: :model do
  let(:tag) { create :tag }

  describe '#name' do
    it 'is not valid without name' do
      tag.name = ''
      expect(tag).not_to be_valid
      expect(tag.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                           field: 'Name'))
    end

    it 'is unique' do
      duplicate_tag = described_class.new(name: tag.name)
      expect(duplicate_tag).not_to be_valid
      expect(duplicate_tag.errors.full_messages.to_sentence).to eq(t('already_taken',
                                                                     field: 'Name'))
    end
  end

  describe '#tag_type' do
    it 'is not valid without tag_type' do
      tag.tag_type = ''
      expect(tag).not_to be_valid
      expect(tag.errors.full_messages.to_sentence).to eq(t('cant_blank',
                                                           field: 'Tag type'))
    end
  end
end
