class AddUnverifiedEmailToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :unverified_email, :string
    add_index :users, :unverified_email, unique: true
  end
end
