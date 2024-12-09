class AddTeamEnrollmentsCountToCourses < ActiveRecord::Migration[7.2]
  def change
    add_column :courses, :team_enrollments_count, :integer, default: 0
  end
end
