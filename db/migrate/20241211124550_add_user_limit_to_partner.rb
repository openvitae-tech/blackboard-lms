class AddUserLimitToPartner < ActiveRecord::Migration[7.2]
  def change
    add_column :learning_partners, :max_user_count, :integer
  end
end
