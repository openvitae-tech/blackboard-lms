# rubocop:disable RSpec/VerifiedDoubles
# frozen_string_literal: true

require 'rails_helper'

describe ExtractAndSaveAudioJob do
  let(:job) { described_class.new }
  let(:local_content) { instance_double(LocalContent, id: 1, video: video_attachment, audio: audio_attachment) }
  let(:video_attachment) { double('video_attachment', blank?: false, attached?: true, blob: blob) }
  let(:audio_attachment) { instance_double(ActiveStorage::Attached::One) }
  let(:blob) { instance_double(ActiveStorage::Blob) }
  let(:file) { instance_double(File, path: '/tmp/video.mp4') }
  let(:audio_io) { StringIO.new('audio data') }
  let(:ffmpeg_service) { instance_double(FfmpegService) }

  before do
    allow(LocalContent).to receive(:find_by).with(id: local_content.id).and_return(local_content)
    allow(local_content).to receive(:save!).and_return(true)
    allow(blob).to receive(:open).and_yield(file)
    allow(FfmpegService).to receive(:instance).and_return(ffmpeg_service)
    allow(ffmpeg_service).to receive(:extract_audio).and_return(audio_io)
    allow(audio_attachment).to receive(:attach)
    allow(SecureRandom).to receive(:uuid).and_return('uuid')
    allow(job).to receive(:log_error_to_sentry)
  end

  describe '#perform' do
    context 'when local_content_id is nil' do
      it 'returns without doing anything' do
        allow(LocalContent).to receive(:find_by).with(id: nil).and_return(nil)
        job.perform(nil)
        expect(audio_attachment).not_to have_received(:attach)
        expect(local_content).not_to have_received(:save!)
      end
    end

    context 'when local_content_id does not exist' do
      it 'returns without doing anything' do
        allow(LocalContent).to receive(:find_by).with(id: 999).and_return(nil)
        job.perform(999)
        expect(audio_attachment).not_to have_received(:attach)
        expect(local_content).not_to have_received(:save!)
      end
    end

    context 'when local_content video is blank' do
      it 'returns without doing anything' do
        allow(local_content).to receive(:video).and_return(video_attachment)
        allow(video_attachment).to receive(:blank?).and_return(true)
        job.perform(local_content.id)
        expect(audio_attachment).not_to have_received(:attach)
      end
    end

    context 'when local_content video is not attached' do
      it 'returns without doing anything' do
        allow(local_content).to receive(:video).and_return(video_attachment)
        allow(video_attachment).to receive(:attached?).and_return(false)
        job.perform(local_content.id)
        expect(audio_attachment).not_to have_received(:attach)
      end
    end

    context 'when audio extraction fails' do
      it 'logs error and does not attach audio' do
        allow(FfmpegService).to receive(:instance).and_return(ffmpeg_service)
        allow(ffmpeg_service).to receive(:extract_audio).and_return(nil)
        job.perform(local_content.id)
        expect(job).to have_received(:log_error_to_sentry).with(/Audio extraction failed/)
        expect(audio_attachment).not_to have_received(:attach)
      end
    end

    context 'when everything is valid' do
      it 'attaches the extracted audio to local_content' do
        allow(TranscribeContentAudioJob).to receive(:perform_async)
        job.perform(local_content.id)
        expect(audio_attachment).to have_received(:attach)
          .with(hash_including(io: audio_io,
                               filename: 'uuid.mp3',
                               content_type: 'audio/mpeg',
                               key: 'audio/uuid.mp3'))
        expect(local_content).to have_received(:save!)
        expect(TranscribeContentAudioJob).to have_received(:perform_async).with(local_content.id)
      end
    end
  end
end
# rubocop:enable RSpec/VerifiedDoubles
