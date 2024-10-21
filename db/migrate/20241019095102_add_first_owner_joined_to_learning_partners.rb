class AddFirstOwnerJoinedToLearningPartners < ActiveRecord::Migration[7.1]
  def change
    add_column :learning_partners, :first_owner_joined, :boolean, :default => false
  end
end
