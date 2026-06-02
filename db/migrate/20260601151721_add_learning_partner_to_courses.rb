class AddLearningPartnerToCourses < ActiveRecord::Migration[8.0]
  def change
    add_reference :courses, :learning_partner, null: true, foreign_key: true
  end
end
