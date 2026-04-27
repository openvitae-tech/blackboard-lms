# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentStudioPolicy do
  let(:learning_partner) { create :learning_partner }
  let(:team) { create :team, learning_partner: }

  describe '#index?' do
    it 'returns true for owner' do
      user = create(:user, :owner, team:, learning_partner:)
      expect(described_class.new(user, nil)).to be_index
    end

    it 'returns true for manager' do
      user = create(:user, :manager, team:, learning_partner:)
      expect(described_class.new(user, nil)).to be_index
    end

    it 'returns false for learner' do
      user = create(:user, :learner, team:, learning_partner:)
      expect(described_class.new(user, nil)).not_to be_index
    end
  end
end
