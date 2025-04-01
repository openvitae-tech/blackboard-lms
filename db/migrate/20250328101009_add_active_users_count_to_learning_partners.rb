class AddActiveUsersCountToLearningPartners < ActiveRecord::Migration[7.2]
  def change
    add_column :learning_partners, :active_users_count, :integer, default: 0, null: false
  end
end
