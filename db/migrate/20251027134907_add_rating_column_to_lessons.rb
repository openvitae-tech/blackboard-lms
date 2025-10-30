class AddRatingColumnToLessons < ActiveRecord::Migration[8.0]
  def change
    add_column :lessons, :rating, :decimal
    add_column :lessons, :last_rated_at, :datetime
  end
end
