class AddFieldsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :phone_confirmation_token, :string
    add_index :users, :phone_confirmation_token, unique: true
    add_column :users, :phone_confirmation_sent_at, :datetime
    add_column :users, :phone_confirmed_at, :datetime
  end
end
