# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MobileNumber do
  subject { described_class.new(value:) }

  context 'validations' do
    context 'when the value is valid' do
      let(:value) { '1234567890' }

      it 'is valid' do
        expect(subject).to be_valid
      end
    end

    context 'when the value is not numerical' do
      let(:value) { 'abcdefghij' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:value]).to include('is not a number')
      end
    end

    context 'when the value is too short' do
      let(:value) { '12345' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:value]).to include('is too short (minimum is 10 characters)')
      end
    end

    context 'when the value is too long' do
      let(:value) { '12345678901' }

      it 'is not valid' do
        expect(subject).not_to be_valid
        expect(subject.errors[:value]).to include('is too long (maximum is 10 characters)')
      end
    end
  end
end
