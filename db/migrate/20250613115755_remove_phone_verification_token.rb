class RemovePhoneVerificationToken < ActiveRecord::Migration[7.2]
  def change
    remove_index :users, :phone_confirmation_token
  end
end
