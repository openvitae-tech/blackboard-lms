# frozen_string_literal: true

require 'rails_helper'

describe ExtractAndSaveAudioJob do
  let(:job) { described_class.new }
  let(:local_content) { instance_double(LocalContent, id: 1, video: video_attachment, audio: audio_attachment) }
  let(:video_attachment) { double(ActiveStorage::Blob, blank?: false, attached?: true, blob: blob) }
  let(:audio_attachment) { double(ActiveStorage::Blob) }
  let(:blob) { double(ActiveStorage::Blob, open: nil) }
  let(:file) { double(File, path: '/tmp/video.mp4') }
  let(:audio_io) { StringIO.new('audio data') }

  before do
    allow(LocalContent).to receive(:find_by).with(id: local_content.id).and_return(local_content)
    allow(local_content).to receive(:save!).and_return(true)
    allow(blob).to receive(:open).and_yield(file)
    allow(FfmpegService).to receive_message_chain(:instance, :extract_audio).and_return(audio_io)
    allow(audio_attachment).to receive(:attach)
    allow(SecureRandom).to receive(:uuid).and_return('uuid')
  end

  describe '#perform' do
    context 'when local_content_id is nil' do
      it 'returns without doing anything' do
        allow(LocalContent).to receive(:find_by).with(id: nil).and_return(nil)
        expect(audio_attachment).not_to receive(:attach)
        expect(local_content).not_to receive(:save!)
        job.perform(nil)
      end
    end

    context 'when local_content_id do not exists' do
      it 'returns without doing anything' do
        allow(LocalContent).to receive(:find_by).with(id: 999).and_return(nil)
        expect(audio_attachment).not_to receive(:attach)
        expect(local_content).not_to receive(:save!)
        job.perform(999)
      end
    end

    context 'when local_content video is blank' do
      it 'returns without doing anything' do
        allow(local_content).to receive(:video).and_return(double(blank?: true))
        expect(local_content.audio).not_to receive(:attach)
        job.perform(local_content.id)
      end
    end

    context 'when local_content video is not attached' do
      it 'returns without doing anything' do
        allow(local_content.video).to receive(:attached?).and_return(false)
        expect(local_content.audio).not_to receive(:attach)
        job.perform(local_content.id)
      end
    end

    context 'when audio extraction fails' do
      it 'logs error and does not attach audio' do
        allow(FfmpegService).to receive_message_chain(:instance, :extract_audio).and_return(nil)
        expect(job).to receive(:log_error_to_sentry).with(/Audio extraction failed/)
        expect(local_content.audio).not_to receive(:attach)
        job.perform(local_content.id)
      end
    end

    context 'when everything is valid' do
      it 'attaches the extracted audio to local_content' do
        expect(local_content.audio).to receive(:attach).with(hash_including(io: audio_io, filename: 'uuid.mp3',
                                                                            content_type: 'audio/mpeg',
                                                                            key: 'audio/uuid.mp3'))
        expect(local_content).to receive(:save!)
        job.perform(local_content.id)
      end
    end
  end
end
