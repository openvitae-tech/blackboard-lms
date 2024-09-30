# frozen_string_literal: true
module TeamsHelper
  def my_team_path
    if current_user.is_admin?
      '#'
    else
      team_path(current_user.team)
    end
  end

  def team_list(team)
    return @team_list if @team_list.present?

    @team_list = []

    while team && team.parent_team != current_user.team
      @team_list.push(team)
      team = team.parent_team
    end

    @team_list
  end
end