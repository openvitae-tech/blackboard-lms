class AddDepartmentToTeams < ActiveRecord::Migration[7.2]
  def change
    add_column :teams, :department, :string
  end
end
