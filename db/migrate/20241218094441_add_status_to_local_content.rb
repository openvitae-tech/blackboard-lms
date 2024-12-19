class AddStatusToLocalContent < ActiveRecord::Migration[7.2]
  def change
    add_column :local_contents, :status, :string
  end
end
