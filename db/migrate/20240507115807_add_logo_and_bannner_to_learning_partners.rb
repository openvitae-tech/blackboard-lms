# frozen_string_literal: true

class AddLogoAndBannnerToLearningPartners < ActiveRecord::Migration[7.1]
  def change
    add_column :learning_partners, :logo, :string
    add_column :learning_partners, :banner, :string
  end
end
