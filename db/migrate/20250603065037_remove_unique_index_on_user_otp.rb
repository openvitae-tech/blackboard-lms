class RemoveUniqueIndexOnUserOtp < ActiveRecord::Migration[7.2]
  def change
    remove_index :users, :otp
  end
end
