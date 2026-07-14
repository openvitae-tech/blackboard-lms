# frozen_string_literal: true

require_relative '../../rails_helper'

RSpec.describe ContentStudio::MockClient do
  subject(:client) { described_class.new }

  before { described_class.reset! }

  describe '#create_microlesson' do
    it 'returns a unique microlesson id string' do
      id = client.create_microlesson(prompt: 'test', document_urls: [], template_id: '1', logo_url: nil)
      expect(id).to be_a(String).and start_with('mock-ml-')
    end

    it 'returns a different id on each call' do
      id1 = client.create_microlesson(prompt: 'a', document_urls: [], template_id: '1', logo_url: nil)
      id2 = client.create_microlesson(prompt: 'b', document_urls: [], template_id: '1', logo_url: nil)
      expect(id1).not_to eq(id2)
    end
  end

  describe '#get_microlesson' do
    let(:microlesson_id) do
      client.create_microlesson(prompt: 'test', document_urls: [], template_id: '1', logo_url: nil)
    end

    it 'returns a Microlesson struct' do
      result = client.get_microlesson(microlesson_id)
      expect(result).to be_a(ContentStudio::Microlesson)
    end

    it 'raises Faraday::ResourceNotFound for an unknown id' do
      expect { client.get_microlesson('unknown-id') }.to raise_error(Faraday::ResourceNotFound)
    end

    it 'starts in PLANNING status' do
      result = client.get_microlesson(microlesson_id)
      expect(result.status).to eq('PLANNING')
    end

    it 'eventually reaches PLANNED status with title and description' do
      results = Array.new(7) { client.get_microlesson(microlesson_id) }
      planned = results.find { |r| r.status == 'PLANNED' }
      expect(planned).not_to be_nil
      expect(planned.title).to be_present
      expect(planned.description).to be_present
    end

    it 'eventually reaches COMPLETED status with video and thumbnail urls' do
      result = nil
      7.times { result = client.get_microlesson(microlesson_id) }
      expect(result.status).to eq('COMPLETED')
      expect(result.video_url).to be_present
      expect(result.thumbnail_url).to be_present
      expect(result.duration).to be_positive
    end
  end

  describe 'failure path (fail_ prompt prefix)' do
    let(:microlesson_id) do
      client.create_microlesson(prompt: 'fail_test', document_urls: [], template_id: '1', logo_url: nil)
    end

    it 'eventually reaches FAILED status' do
      result = nil
      7.times { result = client.get_microlesson(microlesson_id) }
      expect(result.status).to eq('FAILED')
    end

    it 'stays in FAILED on further polls' do
      8.times { client.get_microlesson(microlesson_id) }
      result = client.get_microlesson(microlesson_id)
      expect(result.status).to eq('FAILED')
    end

    it 'returns a Microlesson with only id and status set' do
      result = nil
      7.times { result = client.get_microlesson(microlesson_id) }
      expect(result.video_url).to be_nil
      expect(result.title).to be_nil
    end
  end

  describe '#replan_microlesson' do
    let(:microlesson_id) do
      client.create_microlesson(prompt: 'original', document_urls: [], template_id: '1', logo_url: nil)
    end

    it 'resets the microlesson back to PLANNING' do
      3.times { client.get_microlesson(microlesson_id) }
      client.replan_microlesson(microlesson_id: microlesson_id, prompt: 'revised')
      result = client.get_microlesson(microlesson_id)
      expect(result.status).to eq('PLANNING')
    end

    it 'preserves the existing prompt when no new prompt is given' do
      3.times { client.get_microlesson(microlesson_id) }
      client.replan_microlesson(microlesson_id: microlesson_id)
      expect(described_class.store[microlesson_id][:prompt]).to eq('original')
    end

    it 'preserves the fail flag when no new prompt is given' do
      fail_id = client.create_microlesson(prompt: 'fail_test', document_urls: [], template_id: '1', logo_url: nil)
      client.replan_microlesson(microlesson_id: fail_id)
      expect(described_class.store[fail_id][:fail]).to be true
    end

    it 'updates the prompt and fail flag when a new prompt is given' do
      client.replan_microlesson(microlesson_id: microlesson_id, prompt: 'fail_revised')
      expect(described_class.store[microlesson_id][:prompt]).to eq('fail_revised')
      expect(described_class.store[microlesson_id][:fail]).to be true
    end
  end

  describe '#generate_microlesson' do
    let(:microlesson_id) do
      client.create_microlesson(prompt: 'test', document_urls: [], template_id: '1', logo_url: nil)
    end

    it 'jumps state to GENERATING' do
      client.generate_microlesson(microlesson_id: microlesson_id)
      result = client.get_microlesson(microlesson_id)
      expect(result.status).to eq('GENERATING')
    end
  end
end
