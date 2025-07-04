# frozen_string_literal: true

namespace :one_timer do
  desc 'Recalculate total_members_count for all teams'
  task backfill_total_members_count: :environment do
    leaf_teams = Team.includes(:sub_teams).select { |team| team.sub_teams.empty? }

    leaf_teams.each do |team|
      Teams::UpdateTotalMembersCountService.instance.update_count(team)
    end
  end
end
