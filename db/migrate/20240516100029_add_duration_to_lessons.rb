class AddDurationToLessons < ActiveRecord::Migration[7.1]
  def change
    add_column :lessons, :duration, :integer, default: 0
  end
end
