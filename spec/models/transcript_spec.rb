# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transcript, type: :model do
  let(:local_content) { create(:lesson).local_contents.first }

  describe 'validations' do
    it 'is valid with valid attributes' do
      transcript = build(:transcript, local_content: local_content, start_at: 1, end_at: 2, text: 'Hello')
      expect(transcript).to be_valid
    end

    it 'is invalid if start_at is not before end_at' do
      transcript = build(:transcript, local_content: local_content, start_at: 2, end_at: 1, text: 'Hello')
      expect(transcript).not_to be_valid
      expect(transcript.errors[:base]).to include(I18n.t('transcript.start_time_must_be_before_end_time'))
    end

    it 'is invalid without required attributes' do
      transcript = build(:transcript, local_content: local_content, start_at: nil, end_at: nil, text: nil)
      expect(transcript).not_to be_valid
      expect(transcript.errors[:start_at]).to be_present
      expect(transcript.errors[:end_at]).to be_present
      expect(transcript.errors[:text]).to be_present
    end
  end

  describe '.update_with_transaction' do
    let(:data) do
      [
        { 'text' => 'foo', 'start_ms' => 10, 'end_ms' => 20 },
        { 'text' => 'bar', 'start_ms' => 21, 'end_ms' => 30 }
      ]
    end

    it 'destroys existing transcripts and inserts new ones' do
      create(:transcript, local_content: local_content, start_at: 1, end_at: 2, text: 'old')
      expect do
        Transcript.update_with_transaction(local_content, data)
      end.to change { local_content.transcripts.count }.from(1).to(2)
    end

    it 'inserts correct attributes' do
      Transcript.update_with_transaction(local_content, data)
      expect(local_content.transcripts.count).to eq(2)
    end
  end
end
