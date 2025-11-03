# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FfmpegService do
  let(:service) { described_class.instance }
  let(:input_path) { Rails.root.join('spec/fixtures/files/sample.mp4').to_s }

  before do
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:readable?).and_call_original
  end

  describe '#extract_audio' do
    describe 'input validation' do
      context 'when input_path is blank' do
        it 'raises ArgumentError' do
          expect { service.extract_audio('') }.to raise_error(ArgumentError, /Input path is required/)
        end
      end

      context 'when input file does not exist' do
        it 'raises ArgumentError' do
          allow(File).to receive(:exist?).with(input_path).and_return(false)
          expect { service.extract_audio(input_path) }.to raise_error(ArgumentError, /Input file does not exist/)
        end
      end

      context 'when input file is not readable' do
        it 'raises ArgumentError' do
          allow(File).to receive(:exist?).with(input_path).and_return(true)
          allow(File).to receive(:readable?).with(input_path).and_return(false)
          expect { service.extract_audio(input_path) }.to raise_error(ArgumentError, /Input file is not readable/)
        end
      end
    end

    describe 'ffmpeg execution' do
      context 'when ffmpeg succeeds' do
        it 'returns a StringIO with audio data' do
          allow(File).to receive(:exist?).with(input_path).and_return(true)
          allow(File).to receive(:readable?).with(input_path).and_return(true)
          fake_wait_thr = instance_double(Thread, value: instance_double(Process::Status, success?: true))
          allow(Open3).to receive(:popen3).and_yield(nil, StringIO.new('audio data'), StringIO.new, fake_wait_thr)
          result = service.extract_audio(input_path)
          expect(result).to be_a(StringIO)
          expect(result.string).to eq('audio data')
        end
      end

      context 'when ffmpeg fails' do
        it 'raises an error' do
          allow(File).to receive(:exist?).with(input_path).and_return(true)
          allow(File).to receive(:readable?).with(input_path).and_return(true)
          fake_wait_thr = instance_double(Thread, value: instance_double(Process::Status,
                                                                         success?: false,
                                                                         exitstatus: 1))
          allow(Open3).to receive(:popen3).and_yield(nil, StringIO.new, StringIO.new('error'), fake_wait_thr)
          expect { service.extract_audio(input_path) }.to raise_error(RuntimeError, /FFmpeg command failed/)
        end
      end
    end
  end
end
