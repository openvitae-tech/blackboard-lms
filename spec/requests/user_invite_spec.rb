# frozen_string_literal: true

RSpec.describe 'Request spec for user invites' do
  describe 'Invite new partner users by Admin' do
    before do
      admin_user = create :user, :admin
      @team = create :team
      sign_in admin_user
    end

    it 'Allows inviting new users' do
      params = {
        user: {
          email: Faker::Internet.email,
          role: 'learner',
          team_id: @team.id
        }
      }

      expect do
        post '/invites', params:
      end.to change(User, :count).by(1)
    end
  end

  describe 'Invite new partner users by Manager' do
    before do
      @team = create :team
      manager_user = create :user, :manager, team: @team, learning_partner: @team.learning_partner
      sign_in manager_user
    end

    it 'Allows inviting new users by manager' do
      params = {
        user: {
          email: Faker::Internet.email,
          role: 'learner',
          team_id: @team.id
        }
      }

      expect do
        post '/invites', params:
      end.to change(User, :count).by(1)
    end
  end
end
