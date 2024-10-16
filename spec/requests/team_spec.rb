# frozen_string_literal: true

RSpec.describe 'Request spec for feature team' do
  describe 'Create a new team by manager' do
    before(:each) do
      @team = create :team
      manager = create :user, :manager, team: @team, learning_partner: @team.learning_partner
      sign_in manager
    end

    it 'Allows manager to create a subteam' do
      params = {
        team: {
          name: Faker::Restaurant.name,
          banner: image_file,
          parent_team_id: @team.id
        }
      }

      expect do
        post('/teams', params:)
      end.to change { Team.count }.by(1)
    end

    it 'Allows manager to update a team' do
      params = {
        team: {
          name: Faker::Restaurant.name,
        }
      }

      put("/teams/#{@team.id}", params:)
      expect(@team.reload.name).to eq(params[:team][:name])
    end
  end
end