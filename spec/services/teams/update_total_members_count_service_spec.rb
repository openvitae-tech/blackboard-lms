# frozen_string_literal: true

RSpec.describe Teams::UpdateTotalMembersCountService do
  subject { described_class.instance }

  let(:learning_partner) { create :learning_partner }
  let(:parent_team) { create :team, learning_partner: learning_partner }
  let(:sub_team_one) { create :team, learning_partner: learning_partner, parent_team: parent_team }
  let(:sub_team_two) { create(:team, learning_partner: learning_partner, parent_team: sub_team_one) }

  let(:parent_user) { create(:user, :manager, team: parent_team, learning_partner: learning_partner) }

  describe '#update_count' do
    before do
      create_list :user, 2, :learner, team: sub_team_one, learning_partner: learning_partner
      create_list :user, 3, :learner, team: sub_team_two, learning_partner: learning_partner
    end

    it 'recursively updates the total_members_count for all ancestor teams' do
      subject.update_count(sub_team_two)

      expect(sub_team_two.reload.total_members_count).to eq(3)
      expect(sub_team_one.reload.total_members_count).to eq(5)
    end

    it 'does not perform update if total_members_count is already correct' do
      subject.update_count(sub_team_two)
      expect do
        subject.update_count(sub_team_two)
      end.not_to(change(sub_team_one, :total_members_count))
    end
  end
end
