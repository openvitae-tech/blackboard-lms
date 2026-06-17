# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ContentPolicy do
  let(:learning_partner) { create(:learning_partner) }
  let(:team) { create(:team, learning_partner:) }
  let(:manager) { create(:user, :manager, t_team: team) }
  let(:owner) { create(:user, :owner, t_team: team) }
  let(:learner) { create(:user, :learner, t_team: team) }
  let(:support) { create(:user, :owner, role: 'support', t_team: team) }
  let(:record) { :content }

  describe '#index?' do
    it 'allows managers' do
      expect(described_class.new(manager, record)).to be_index
    end

    it 'allows owners' do
      expect(described_class.new(owner, record)).to be_index
    end

    it 'allows support users' do
      expect(described_class.new(support, record)).to be_index
    end

    it 'denies learners' do
      expect(described_class.new(learner, record)).not_to be_index
    end
  end
end
