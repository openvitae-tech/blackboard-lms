# frozen_string_literal: true

class CreateLearningPartners < ActiveRecord::Migration[7.1]
  def change
    create_table :learning_partners do |t|
      t.string :name
      t.text :about

      t.timestamps
    end
  end
end
