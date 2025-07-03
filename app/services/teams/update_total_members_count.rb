# frozen_string_literal: true

module Teams
  class UpdateTotalMembersCount
    include Singleton

    def update_count(team)
      return unless team

      # skipping support user and deactivated users
      total = team.members.count + team.sub_teams.sum(&:total_members_count)
      team.update!(total_members_count: total)

      update_count(team.parent_team)
    end
  end
end
