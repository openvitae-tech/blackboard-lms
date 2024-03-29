class AddTeamNameToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :team_name, :string
  end
end
