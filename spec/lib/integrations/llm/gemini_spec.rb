# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Integrations::Llm::Gemini do
  subject(:gemini) { described_class.new(described_class::DEFAULT_MODEL) }

  let(:prompt) { 'Explain Ruby meta-programming' }

  before do
    mock_response = double('RubyLLM::Response', content: 'Ruby meta-programming is powerful.') # rubocop:disable RSpec/VerifiedDoubles
    mock_service = double( # rubocop:disable RSpec/VerifiedDoubles
      'RubyLLM::Chat',
      with_params: nil,
      ask: mock_response
    )

    allow(RubyLLM).to receive(:chat).and_return(mock_service)
    gemini.model = described_class::DEFAULT_MODEL
  end

  describe 'constants' do
    it 'has supported models' do
      expect(described_class::SUPPORTED_MODELS).to include('gemini-2.5-pro', 'gemini-2.5-flash',
                                                           'gemini-2.5-flash-lite')
    end

    it 'has a default model' do
      expect(described_class::DEFAULT_MODEL).to eq('gemini-2.5-flash')
    end
  end

  describe '#chat' do
    it 'returns response' do
      result = gemini.send(:ask, prompt)
      expect(result.data).to eq('Ruby meta-programming is powerful.')
    end

    it 'raises error for unsupported model' do
      expect do
        Integrations::Llm::Api.llm_instance(provider: :gemini, model: 'invalid-model')
      end.to raise_error(ArgumentError,
                         /Unsupported model 'invalid-model' for gemini. Allowed: gemini-2.5-pro, gemini-2.5-flash, gemini-2.5-flash-lite/) # rubocop:disable Layout/LineLength
    end

    it 'raises error for unsupported provider' do
      expect do
        Integrations::Llm::Api.llm_instance(provider: :unknown)
      end.to raise_error(ArgumentError, /Unsupported LLM provider: unknown./)
    end
  end
end
