class AddRatingColumnToCourses < ActiveRecord::Migration[8.0]
  def change
    add_column :courses, :rating, :decimal
  end
end
