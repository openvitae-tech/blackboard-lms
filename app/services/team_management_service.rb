# frozen_string_literal: true

class TeamManagementService
  include Singleton

  def create_team(team_params, partner)
    team = Team.new(name: team_params[:name], learning_partner: partner, parent_team_id: team_params[:parent_team_id])
    # Test fails with this code
    # if partner.banner.attached?
    #   partner.banner.open do |tempfile|
    #     team.banner.attach(
    #       io: tempfile,
    #       filename: partner.banner.blob.filename.to_s,
    #       content_type: partner.banner.blob.content_type.to_s
    #     )
    #   end
    # end

    team.save
  end

  def update_team!(team, team_params)
    team.update!(team_params)
  end
end
