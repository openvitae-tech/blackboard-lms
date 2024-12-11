class AddTeamEnrollmentsCountToTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :teams, :team_enrollments_count, :integer, default: 0
  end
end
