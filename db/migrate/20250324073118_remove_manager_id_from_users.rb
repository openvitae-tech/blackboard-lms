class RemoveManagerIdFromUsers < ActiveRecord::Migration[7.2]
  def change
    remove_column :users, :manager_id
  end
end
