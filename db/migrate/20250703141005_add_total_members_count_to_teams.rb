class AddTotalMembersCountToTeams < ActiveRecord::Migration[8.0]
  def change
    add_column :teams, :total_members_count, :integer, default: 0, null: false
  end
end
