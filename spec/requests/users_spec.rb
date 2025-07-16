# frozen_string_literal: true

RSpec.describe 'Request spec for Users' do
  let(:user) { create :user, :admin }
  let(:learning_partner) { create :learning_partner }
  let(:parent_team) { create :team, learning_partner: }
  let(:sub_team) { create :team, parent_team:, learning_partner: }
  let(:manager) { create :user, :manager, team: parent_team, learning_partner: }

  before do
    @learner = create(:user, :manager, team: sub_team, learning_partner:)
    sub_team.update!(total_members_count: 1)
    sign_in manager
  end

  describe 'GET /change_team' do
    it 'renders the change_team template' do
      get change_team_member_path(@learner)
      expect(response.status).to be(200)

      expect(response).to render_template(:change_team)
      expect(assigns(:teams).pluck(:id)).to eq([parent_team.id, sub_team.id])
    end

    it 'Unauthorized when change_team is accessed by learner' do
      sign_in @learner

      get change_team_member_path(@learner)
      expect(response).to redirect_to(error_401_path)
      expect(flash[:notice]).to eq(I18n.t('pundit.unauthorized'))
    end
  end

  describe 'PATCH /confirm_change_team' do
    it 'updates the user team' do
      new_team = create(:team, parent_team:, learning_partner:)
      expect do
        patch confirm_change_team_member_path(@learner), params: { user: { team_id: new_team.id } }
      end.to change { @learner.reload.team }.to(new_team)

      expect(flash.now[:success]).to eq('Team changed successfully')
    end

    it 'updating user team should update the team total_members_count' do
      new_team = create(:team, parent_team:, learning_partner:)

      patch confirm_change_team_member_path(@learner), params: { user: { team_id: new_team.id } }

      expect(new_team.reload.total_members_count).to eq(1)
      expect(sub_team.reload.total_members_count).to eq(0)
    end

    it 'return when team not selected' do
      patch confirm_change_team_member_path(@learner), params: { user: { team_id: '' } }

      expect(assigns(:user).errors[:team_id]).to include('must be selected')
      expect(response).to render_template(:change_team)
      expect(response.status).to eq(422)
    end
  end
end
