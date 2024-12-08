class AddAssignedByToTeamEnrollents < ActiveRecord::Migration[7.2]
  def change
    add_reference(:team_enrollments, :assigned_by, foreign_key: { to_table: :users })
  end
end
