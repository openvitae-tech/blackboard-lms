class AddCommunicationChannelToUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :communication_channels, :string, array: true, default: ["sms"]

    User.update_all(communication_channels: ["sms"])

    change_column_null :users, :communication_channels, false
  end

  def down
    remove_column :users, :communication_channels
  end
end
