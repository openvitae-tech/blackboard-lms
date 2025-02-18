class RenameOtpDigestToOtpInUsers < ActiveRecord::Migration[7.2]
  def change
    change_column :users, :otp_digest, :string
    rename_column :users, :otp_digest, :otp

    add_index :users, :otp, unique: true
  end
end
