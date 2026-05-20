# frozen_string_literal: true

class AddContentStudioCreatorToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :content_studio_creator, :boolean, default: false, null: false
  end
end
