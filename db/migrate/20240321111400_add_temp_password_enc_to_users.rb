class AddTempPasswordEncToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :temp_password_enc, :string
  end
end
