class AddUsersCountToLearningPartners < ActiveRecord::Migration[7.2]
  def change
    add_column :learning_partners, :users_count, :integer, default: 0
  end
end
