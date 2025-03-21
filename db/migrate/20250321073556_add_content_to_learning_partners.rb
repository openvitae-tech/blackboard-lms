class AddContentToLearningPartners < ActiveRecord::Migration[7.2]
  def change
    add_column :learning_partners, :content, :text
  end
end
