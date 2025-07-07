# frozen_string_literal: true

module Teams
  class UpdateTotalMembersCountService
    include Singleton

    def update_count(team)
      return unless team

      total = team.members.size + team.sub_teams.sum(&:total_members_count)
      team.update!(total_members_count: total)

      update_count(team.parent_team)
    end
  end
end
