# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClassroomKitPolicy, type: :policy do
  subject { described_class.new(user, kit) }

  let(:learning_partner) { create(:learning_partner) }
  let(:team) { create(:team, learning_partner:) }
  let(:kit) { create(:classroom_kit, learning_partner:) }

  describe '#index? / #show?' do
    context 'when user is a manager' do
      let(:user) { create(:user, :manager, t_team: team) }

      it { is_expected.to be_index }
      it { is_expected.to be_show }
    end

    context 'when user is an owner' do
      let(:user) { create(:user, :owner, t_team: team) }

      it { is_expected.to be_index }
      it { is_expected.to be_show }
    end

    context 'when user is an admin' do
      let(:user) { create(:user, :admin) }

      it { is_expected.not_to be_index }
      it { is_expected.not_to be_show }
    end

    context 'when user is a learner' do
      let(:user) { create(:user, :learner, t_team: team) }

      it { is_expected.not_to be_index }
      it { is_expected.not_to be_show }
    end
  end

  describe '#save?' do
    context 'when user is a content studio creator' do
      let(:user) { create(:user, :manager, t_team: team, content_studio_creator: true) }

      it { is_expected.to be_save }
    end

    context 'when user is a manager without creator flag' do
      let(:user) { create(:user, :manager, t_team: team) }

      it { is_expected.not_to be_save }
    end

    context 'when user is a learner' do
      let(:user) { create(:user, :learner, t_team: team) }

      it { is_expected.not_to be_save }
    end
  end
end
