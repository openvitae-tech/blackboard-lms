# frozen_string_literal: true

class AddLocalLangToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :preferred_local_language, :string
  end
end
