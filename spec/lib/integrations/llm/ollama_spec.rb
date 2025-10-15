# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Integrations::Llm::Ollama do
  subject(:ollama) { described_class.new(described_class::DEFAULT_MODEL) }

  let(:prompt) { 'Explain Ruby meta-programming' }

  before do
    mock_response = double('RubyLLM::Response', content: 'Ruby meta-programming is powerful.') # rubocop:disable RSpec/VerifiedDoubles
    mock_service = double( # rubocop:disable RSpec/VerifiedDoubles
      'RubyLLM::Chat',
      with_params: nil,
      ask: mock_response
    )

    allow(RubyLLM).to receive(:chat).and_return(mock_service)
    ollama.model = described_class::DEFAULT_MODEL
  end

  describe 'constants' do
    it 'defines supported models' do
      expect(described_class::SUPPORTED_MODELS).to eq(%w[gemma3:latest])
    end

    it 'defines a default model' do
      expect(described_class::DEFAULT_MODEL).to eq('gemma3:latest')
    end
  end

  describe '#chat' do
    it 'returns response' do
      result = ollama.send(:ask, prompt)
      expect(result.data).to eq('Ruby meta-programming is powerful.')
    end

    it 'raises error for unsupported model' do
      expect do
        Integrations::Llm::Api.llm_instance(provider: :ollama, model: 'invalid-model')
      end.to raise_error(ArgumentError, /Unsupported model 'invalid-model'. Allowed: gemma3:latest/)
    end

    it 'raises error for unsupported provider' do
      expect do
        Integrations::Llm::Api.llm_instance(provider: :unknown)
      end.to raise_error(ArgumentError, /Unsupported LLM provider: unknown./)
    end
  end
end
