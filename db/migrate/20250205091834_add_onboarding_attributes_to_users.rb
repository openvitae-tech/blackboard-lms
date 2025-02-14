# frozen_string_literal: true

class AddOnboardingAttributesToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :preferred_local_language, :string
    add_column :users, :gender, :string
    add_column :users, :dob, :date
  end
end
