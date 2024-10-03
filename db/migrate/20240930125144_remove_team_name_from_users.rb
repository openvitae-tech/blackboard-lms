class RemoveTeamNameFromUsers < ActiveRecord::Migration[7.1]
  def change
    remove_column :users, :team_name
  end
end
