class RenameOtpColumnInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :otp, :string
    rename_column :users, :otp, :otp_digest
  end
end
