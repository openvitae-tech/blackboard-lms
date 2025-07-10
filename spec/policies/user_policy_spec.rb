# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy do
  let(:user) { create :user, :admin }
  let(:learning_partner) { create :learning_partner }
  let(:parent_team) { create :team, learning_partner: }
  let(:sub_team) { create :team, parent_team:, learning_partner: }

  describe '#change_team?' do
    before do
      @learner = create(:user, :learner, team: sub_team, learning_partner:)
      @manager = create(:user, :manager, team: sub_team, learning_partner:)
      @owner = create(:user, :owner, team: parent_team, learning_partner:)
    end

    it 'returns false if user is not privileged user' do
      expect(described_class.new(@learner, @manager)).not_to be_change_team
    end

    it 'returns false if changing own team' do
      expect(described_class.new(@manager, @manager)).not_to be_change_team
    end

    it 'returns false if changing owner' do
      new_owner = create(:user, :owner, team: parent_team, learning_partner:)

      expect(described_class.new(new_owner, @owner)).not_to be_change_team
    end

    it 'returns false if manager trying to change team of another manager belongs to same team' do
      new_manager = create(:user, :manager, team: sub_team, learning_partner:)
      expect(described_class.new(@manager, new_manager)).not_to be_change_team
    end

    it 'returns false if sub team manager trying to change team of parent team manager' do
      new_manager = create(:user, :manager, team: parent_team, learning_partner:)
      expect(described_class.new(@manager, new_manager)).not_to be_change_team
    end

    it 'manager can change team of any manager in its sub teams' do
      new_manager = create(:user, :manager, team: parent_team, learning_partner:)
      expect(described_class.new(new_manager, @manager)).to be_change_team
    end

    it 'manager can change team of any learner' do
      expect(described_class.new(@manager, @learner)).to be_change_team
    end

    it 'owner can change team of any learner/manager' do
      expect(described_class.new(@owner, @manager)).to be_change_team
      expect(described_class.new(@owner, @learner)).to be_change_team
    end

    it 'support user can change team of any learner/manager' do
      support_user = create(:user, :owner, role: 'support', team: parent_team, learning_partner:)

      expect(described_class.new(support_user, @manager)).to be_change_team
      expect(described_class.new(support_user, @learner)).to be_change_team
    end

    it 'returns false if user but not manager of that user' do
      new_manager = create(:user, :manager)
      expect(described_class.new(new_manager, @learner)).not_to be_change_team
    end
  end
end
