class AddVisibilityColumnToLearningPartners < ActiveRecord::Migration[8.0]
  def change
    add_column :learning_partners, :is_public, :boolean, default: false
  end
end
