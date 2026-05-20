# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentStudioPolicy do
  let(:learning_partner) { create :learning_partner }
  let(:team) { create :team, learning_partner: }

  describe '#index?' do
    context 'when partner has content studio enabled and user is a creator' do
      before { create(:payment_plan, learning_partner:, content_studio_enabled: true) }

      it 'returns true for owner with creator flag' do
        user = create(:user, :owner, team:, learning_partner:, content_studio_creator: true)
        expect(described_class.new(user, nil)).to be_index
      end

      it 'returns true for manager with creator flag' do
        user = create(:user, :manager, team:, learning_partner:, content_studio_creator: true)
        expect(described_class.new(user, nil)).to be_index
      end

      it 'returns false for owner without creator flag' do
        user = create(:user, :owner, team:, learning_partner:)
        expect(described_class.new(user, nil)).not_to be_index
      end
    end

    context 'when partner has content studio disabled' do
      before { create(:payment_plan, learning_partner:, content_studio_enabled: false) }

      it 'returns false even when user has creator flag' do
        user = create(:user, :owner, team:, learning_partner:, content_studio_creator: true)
        expect(described_class.new(user, nil)).not_to be_index
      end
    end

    context 'when user has no creator flag' do
      before { create(:payment_plan, learning_partner:, content_studio_enabled: true) }

      it 'returns false for learner' do
        user = create(:user, :learner, team:, learning_partner:)
        expect(described_class.new(user, nil)).not_to be_index
      end
    end
  end
end
