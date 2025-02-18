class AddUniqueIndexToUsersPhone < ActiveRecord::Migration[7.2]
  def change
    add_index :users, :phone, unique: true
  end
end
