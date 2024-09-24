# frozen_string_literal: true

class AddLearningPartnerIdToUsers < ActiveRecord::Migration[7.1]
  def change
    add_reference :users, :learning_partner, foreign_key: true
  end
end
