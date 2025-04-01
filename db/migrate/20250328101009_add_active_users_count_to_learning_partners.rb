class AddActiveUsersCountToLearningPartners < ActiveRecord::Migration[7.2]
  def up
    add_column :learning_partners, :active_users_count, :integer, default: 0, null: false

    LearningPartner.find_each do |learning_partner|
      active_users = learning_partner.users.where(state: "active")
      learning_partner.update_column(:active_users_count, active_users.count)
    end
  end
end
