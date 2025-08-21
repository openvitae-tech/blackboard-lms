# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MobileNumber do
  subject { described_class.new(value:, country_code:) }

  describe 'validations' do
    context 'when the value is valid' do
      let(:value) { '1234567890' }
      let(:country_code) { AVAILABLE_COUNTRIES[:india][:code] }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    describe 'when the value is not numerical' do
      let(:value) { 'abcdefghij' }
      let(:country_code) { AVAILABLE_COUNTRIES[:india][:code] }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:value]).to include('is not a number')
      end
    end

    describe 'when the value is too short for indian number' do
      let(:value) { '12345' }
      let(:country_code) { AVAILABLE_COUNTRIES[:india][:code] }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:value].to_sentence).to eq('is not a valid Indian number')
      end
    end

    describe 'when too long for Indian number' do
      let(:value) { '12345678901' }
      let(:country_code) { AVAILABLE_COUNTRIES[:india][:code] }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:value].to_sentence).to eq('is not a valid Indian number')
      end
    end

    describe 'when too short for UAE number' do
      let(:value) { '12345' }
      let(:country_code) { AVAILABLE_COUNTRIES[:uae][:code] }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:value].to_sentence).to eq('is not a valid UAE number')
      end
    end
  end
end
