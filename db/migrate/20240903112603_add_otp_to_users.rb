class AddOtpToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :otp, :integer
    add_column :users, :otp_generated_at, :datetime
  end
end
