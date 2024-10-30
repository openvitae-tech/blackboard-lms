# frozen_string_literal: true
module TeamsHelper
  def my_team_path
    if current_user.is_admin?
      '#'
    else
      team_path(current_user.team)
    end
  end

  def team_list(root_team, team)
    return [] if team.nil?

    return [team] if team.parent_team.nil? || root_team.id == team.id

    team_list = []

    while team
      team_list.push(team)

      if team.parent_team&.id == root_team.id
        team_list.push(team.parent_team)
        break
      end

      team = team.parent_team
    end

    team_list.reverse
  end

  def save_button_label_for(team)
    team.persisted? ? 'Update team' : 'Create team'
  end

  def model_title_label_for(team)
    team.persisted? ? 'Update team' : 'Create team'
  end

  def team_banner(user)
    asset = user.is_admin? ? nil : user.team.banner
    asset || STATIC_ASSETS[:placeholders][:team_banner]
  end
end