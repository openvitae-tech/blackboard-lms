class AddCommunicationChannelToUsers < ActiveRecord::Migration[7.2]
  def up
    add_column :users, :communication_channel, :string

    User.update_all(communication_channel: "sms")

    change_column_null :users, :communication_channel, false
  end

  def down
    remove_column :users, :communication_channel
  end
end
