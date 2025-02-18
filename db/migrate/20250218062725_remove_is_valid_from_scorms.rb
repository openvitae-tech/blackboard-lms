class RemoveIsValidFromScorms < ActiveRecord::Migration[7.2]
  def change
    remove_column :scorms, :is_valid
  end
end
