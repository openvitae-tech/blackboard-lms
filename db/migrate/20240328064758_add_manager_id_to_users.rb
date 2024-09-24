# frozen_string_literal: true

class AddManagerIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :manager, index: true
  end
end
