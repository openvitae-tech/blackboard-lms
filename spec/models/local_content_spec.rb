# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocalContent, type: :model do
  let(:lesson) { create :lesson }
  let(:local_content) { lesson.local_contents.first }

  describe '#title' do
    it 'should not be valid without language' do
      local_content.lang = ''
      expect(local_content).not_to be_valid
      expect(local_content.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                          field: 'Lang'))
    end
  end

  describe '#blob_id' do
    it 'should not be valid without blob' do
      local_content.blob_id = ''
      expect(local_content).not_to be_valid
      expect(local_content.errors.full_messages.to_sentence).to include(t('local_content.video_not_found',
                                                                          lang: 'english'))
    end

    it 'should attach blob to video' do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'sample_video.mp4')),
        filename: 'sample_video.mp4',
        content_type: 'video/mp4'
      )
      local_content.video.attach(blob)
      expect(local_content.video.blob.id).to eq(blob.id)
    end
  end

  describe '#lesson' do
    it 'should not be valid without lesson' do
      local_content.lesson = nil
      expect(local_content).not_to be_valid
      expect(local_content.errors.full_messages.to_sentence).to include(t('must_exist',
                                                                          entity: 'Lesson'))
    end
  end
end
