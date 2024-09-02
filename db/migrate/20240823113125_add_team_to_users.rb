class AddTeamToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :team, foreign_key: true
  end
end
