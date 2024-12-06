class CreateTeamEnrollments < ActiveRecord::Migration[7.2]
  def change
    create_table :team_enrollments do |t|
      t.references :team, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true

      t.timestamps
    end
  end
end
