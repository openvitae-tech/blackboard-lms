# frozen_string_literal: true

class TeamManagementService
  include Singleton

  def create_team!(team_params, partner)
    Team.create!(
      name: team_params[:name],
      banner: team_params[:banner],
      learning_partner: partner,
      parent_team_id: team_params[:parent_team_id]
    )
  end

  def update_team!(team, team_params)
    team.update!(team_params)
  end
end
