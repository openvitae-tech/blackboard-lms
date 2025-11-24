# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TranscribeContentAudioJob do
  let(:local_content_id) { 42 }
  let(:local_content) do
    instance_double(LocalContent,
                    id: local_content_id,
                    audio: instance_double(ActiveStorage::Blob))
  end
  let(:service) { instance_double(AudioTranscriptionService) }
  let(:transcripts_data) { instance_double(Array, count: 10) }

  before do
    allow(LocalContent).to receive(:find).with(local_content_id).and_return(local_content)
    allow(AudioTranscriptionService).to receive(:instance).and_return(service)
    allow(service).to receive(:transcribe).with(local_content.audio)
                  .and_return(Result.ok({ 'segments' => transcripts_data }))
    allow(Transcript).to receive(:update_with_transaction)
  end

  describe '#perform' do
    it 'finds the local_content and transcribes audio' do
      described_class.new.perform(local_content_id)
      expect(LocalContent).to have_received(:find).with(local_content_id)
      expect(service).to have_received(:transcribe).with(local_content.audio)
    end

    it 'updates transcript if result is ok' do
      described_class.new.perform(local_content_id)
      expect(Transcript).to have_received(:update_with_transaction).with(local_content, transcripts_data)
    end

    it 'does not update transcript if result is not ok' do
      allow(service).to receive(:transcribe).with(local_content.audio)
                    .and_return(Result.error('LLM model error'))
      expect do
        described_class.new.perform(local_content_id)
      end.to raise_error(StandardError, /Transcription failed: LLM model error/)
    end
  end
end
