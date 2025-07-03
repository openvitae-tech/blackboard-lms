# frozen_string_literal: true

namespace :one_timer do
  desc 'Recalculate total_members_count for all teams'
  task backfill_total_members_count: :environment do
    Team.includes(:sub_teams, :users).find_each do |team|
      all_descendant_teams = []
      teams_to_process = team.sub_teams.to_a

      until teams_to_process.empty?
        current_team = teams_to_process.shift
        all_descendant_teams << current_team
        teams_to_process.concat(current_team.sub_teams)
      end

      active_members = team.members
      descendant_members = all_descendant_teams.flat_map(&:members)

      total_members_count = active_members.count + descendant_members.count
      team.update!(total_members_count: total_members_count)
    end
  end
end
