# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DashboardPolicy do
  let(:learning_partner) { create(:learning_partner) }
  let(:team) { create(:team, learning_partner:) }
  let(:manager) { create(:user, :manager, t_team: team) }
  let(:owner) { create(:user, :owner, t_team: team) }
  let(:learner) { create(:user, :learner, t_team: team) }
  let(:support) { create(:user, :owner, role: 'support', t_team: team) }
  let(:record) { :dashboard }

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

  describe '#team_progress?' do
    it 'allows privileged users' do
      expect(described_class.new(manager, record)).to be_team_progress
    end

    it 'denies learners' do
      expect(described_class.new(learner, record)).not_to be_team_progress
    end
  end

  describe '#team_member_profile?' do
    it 'allows privileged users' do
      expect(described_class.new(manager, record)).to be_team_member_profile
    end

    it 'denies learners' do
      expect(described_class.new(learner, record)).not_to be_team_member_profile
    end
  end

  describe '#started_vs_completed?' do
    it 'allows privileged users' do
      expect(described_class.new(owner, record)).to be_started_vs_completed
    end

    it 'denies learners' do
      expect(described_class.new(learner, record)).not_to be_started_vs_completed
    end
  end

  describe '#recent_activity?' do
    it 'allows privileged users' do
      expect(described_class.new(manager, record)).to be_recent_activity
    end

    it 'denies learners' do
      expect(described_class.new(learner, record)).not_to be_recent_activity
    end
  end

  describe '#appreciate_member?' do
    it 'allows privileged users' do
      expect(described_class.new(manager, record)).to be_appreciate_member
    end

    it 'denies learners' do
      expect(described_class.new(learner, record)).not_to be_appreciate_member
    end
  end

  describe '#nudge_all?' do
    it 'allows managers' do
      expect(described_class.new(manager, record)).to be_nudge_all
    end

    it 'allows owners' do
      expect(described_class.new(owner, record)).to be_nudge_all
    end

    it 'denies learners' do
      expect(described_class.new(learner, record)).not_to be_nudge_all
    end
  end

  describe '#nudge_user?' do
    it 'allows privileged users' do
      expect(described_class.new(manager, record)).to be_nudge_user
    end

    it 'denies learners' do
      expect(described_class.new(learner, record)).not_to be_nudge_user
    end
  end
end
