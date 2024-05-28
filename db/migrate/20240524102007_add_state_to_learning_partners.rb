class AddStateToLearningPartners < ActiveRecord::Migration[7.1]
  def change
    add_column :learning_partners, :state, :string, default: "new"
  end
end
