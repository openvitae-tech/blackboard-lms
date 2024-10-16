# frozen_string_literal: true

class TeamManagementService
  include Singleton

  def create_team(team, partner)
    team.learning_partner = partner
    team.save
  end

  def update_team(team, team_params)
    team.update(team_params)
  end
end
