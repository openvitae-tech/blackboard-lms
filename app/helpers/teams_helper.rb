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

  def team_breadcrumbs_links(root_team, team)
    list = team_list(root_team, team).map { |item| [item.name, team_path(item)] }
    last = list.pop
    list.push([last[0], nil])
  end

  def save_button_label_for(team)
    team.persisted? ? 'Update team' : 'Create team'
  end

  def model_title_label_for(team)
    team.persisted? ? 'Update team' : 'Create team'
  end

  def team_banner(team, version)
    if team.banner.attached?
      resize_banner(team.banner, version)
    else
      version == 'mobile' ? STATIC_ASSETS[:banner_mobile] : STATIC_ASSETS[:banner_desktop]
    end
  end

  def partner_logo(learning_partner, version)
    return STATIC_ASSETS[:logo] unless learning_partner.logo.attached?

    if version == :small
      learning_partner.logo.variant(resize_to_limit: [80, nil])
    else
      learning_partner.logo.variant(resize_to_limit: [150, nil])
    end
  end

  def partner_banner(learning_partner)
    return STATIC_ASSETS[:team_banner] unless learning_partner.banner.attached?

    learning_partner.banner.variant(resize_to_limit: [320, nil])
  end

  private

  def resize_banner(banner, version)
    case version
    when 'desktop'
      banner.variant(resize_to_fill: [1120, 194])
    when 'mobile'
      banner.variant(resize_to_fill: [328, 194])
    else
      banner
    end
  end
end
