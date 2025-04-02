class RemoveMaxUserCountFromLearningPartner < ActiveRecord::Migration[7.2]
  def change
    remove_column :learning_partners, :max_user_count
  end
end
