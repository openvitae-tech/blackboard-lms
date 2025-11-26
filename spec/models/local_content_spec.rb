# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

RSpec.describe LocalContent, type: :model do
  let(:lesson) { create :lesson }
  let(:local_content) { lesson.local_contents.first }
  let(:audio_file) { StringIO.new('audio data') }

  describe '#title' do
    it 'is not valid without language' do
      local_content.lang = ''
      expect(local_content).not_to be_valid
      expect(local_content.errors.full_messages.to_sentence).to include(t('cant_blank',
                                                                          field: 'Lang'))
    end
  end

  describe '#blob_id' do
    it 'is not valid without blob' do
      local_content.blob_id = ''
      local_content.video.detach

      expect(local_content).not_to be_valid
      expect(local_content.errors.full_messages.to_sentence).to include(t('local_content.video_not_found',
                                                                          lang: 'english'))
    end

    it 'attaches blob to video' do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: Rails.root.join('spec/fixtures/files/sample_video.mp4').open,
        filename: 'sample_video.mp4',
        content_type: 'video/mp4'
      )
      local_content.video.attach(blob)
      expect(local_content.video.blob.id).to eq(blob.id)
    end
  end

  describe '#lesson' do
    it 'is not valid without lesson' do
      local_content.lesson = nil
      expect(local_content).not_to be_valid
      expect(local_content.errors.full_messages.to_sentence).to include(t('must_exist',
                                                                          entity: 'Lesson'))
    end
  end

  describe '#transcribe_audio callback' do
    it 'enqueues TranscribeContentAudioJob when audio is attached to english content' do
      local_content.lang = 'english'
      local_content.save!

      audio_blob = ActiveStorage::Blob.create_and_upload!(
        io: audio_file,
        filename: 'sample-audio.mp3',
        content_type: 'audio/mpeg'
      )

      expect do
        local_content.audio.attach(audio_blob)
        local_content.save!
      end.to change(TranscribeContentAudioJob.jobs, :size)

      expect(TranscribeContentAudioJob.jobs.last['args']).to eq([local_content.id])
    end

    it 'does not enqueue TranscribeContentAudioJob for non-english content' do
      local_content.lang = 'hindi'
      local_content.save!

      audio_blob = ActiveStorage::Blob.create_and_upload!(
        io: audio_file,
        filename: 'sample-audio.mp3',
        content_type: 'audio/mpeg'
      )

      expect do
        local_content.audio.attach(audio_blob)
        local_content.save!
      end.not_to change(TranscribeContentAudioJob.jobs, :size)
    end

    it 'does not enqueue TranscribeContentAudioJob when audio is not attached' do
      local_content.lang = 'english'

      expect do
        local_content.save!
      end.not_to change(TranscribeContentAudioJob.jobs, :size)
    end
  end
end
