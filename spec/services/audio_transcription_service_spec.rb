# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AudioTranscriptionService do
  let(:service) { described_class.instance }
  let(:audio) { instance_double(ActiveStorage::Blob) }
  let(:file) { instance_double(File, path: '/tmp/audio.mp3') }
  let(:llm_instance) { instance_double(Integrations::Llm::Gemini) }
  let(:result) { instance_double(Result, ok?: true, data: { 'segments' => [] }) }

  before do
    allow(audio).to receive(:blank?).and_return(false)
    allow(audio).to receive(:open).and_yield(file)
    allow(Integrations::Llm::Api).to receive(:llm_instance).with(provider: :gemini).and_return(llm_instance)
    allow(llm_instance).to receive(:generate_transcript).with(file.path).and_return(result)
  end

  describe '#transcribe' do
    context 'when audio is not attached' do
      it 'raises an error' do
        allow(audio).to receive(:blank?).and_return(true)
        expect { service.transcribe(audio) }.to raise_error(StandardError, 'Audio file is not attached')
      end
    end

    context 'when transcription is successful' do
      it 'returns transcript segments' do
        expect(service.transcribe(audio)).to eq(result)
      end
    end

    context 'when transcription fails' do
      it 'logs error and returns nil' do
        allow(result).to receive(:ok?).and_return(false)
        allow(service).to receive(:log_error_to_sentry)
        expect(service.transcribe(audio)).to eq(result)
      end
    end
  end
end
