class TeamAndUserToReports < ActiveRecord::Migration[8.0]
  def change
    add_reference :reports, :team, null: true, foreign_key: true
    add_reference :reports, :user, null: true, foreign_key: true
    # this is to take advantage of the add_reference function above
    rename_column :reports, :user_id, :generated_by
  end
end
